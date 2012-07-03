class RailsInfo::Logs::Server
  def initialize(options = {log: {}, debug: false})
    options ||= {log: {}, debug: false}
    options[:log] ||= {}
    
    @debug = options[:debug]
    path = options[:log][:path] || "#{Rails.root}/log/"
    env = options[:log][:env] || Rails.env
    @body = options[:log][:body] 
    
    unless @body
      file_path = "#{path}#{env}.log"
      
      @body = File.new(file_path, 'r').read if File.exist?(file_path)
    end
    
    @log ||= {}
    @writes = {}
    
    process if @body.present?
  end
  
  def hash
    @log
  end  
  
  def writes
    @writes
  end
  
  private
  
  def process
    @start_after_last_shutdown = true
    @body = @body.split("\n").map(&:strip)

    reset_log
    
    group_by_action = false

    @body.each do |line|
      if line.match('Processing') && line.match('#') && line.match(/\[/)  && line.match(/\]/)
        # rails 2
        group_by_action = true
      elsif line.match('Started') && line.match(' for ') && line.match(' at ') && line.split(' ').length == 9
        # rails 3
        group_by_action = true
      elsif line.match('Processing by') && line.match('#') && line.match(' as ') && line.split(' ').length == 5
        # rails 3
        group_by_action = true
      end
    end

    unless group_by_action
      @action = 'no_action_grouping'
      @log[@action] ||= { 'Parameters' => '', 'WRITE' => {}, 'READ' => [], 'views' => [], 'misc' => [], 'errors' => []}
    end
    
    @body.each do |line|
      process_line(line)
    end

    @log.each do |action,tabs|
      tabs.each do |tab,content|
        @log[action].delete(tab) if @log[action][tab].blank?
      end
    end

    @log.each do |action,tabs|
      tabs.each do |tab,content|
        next unless tab == 'WRITE'

        # define WHERE column as last one
        content.each do |table_name,data|
          @log[action][tab][table_name]['columns'] << 'WHERE'
        end

        break
      end
    end

    @writes.each do |table_name,data|
      @writes[table_name]['columns'] << 'WHERE'
    end
  end
  
  def reset_log
    @log, @action_indexes, @action, @last_action = {}, {}, "", ""
  end

  # TODO: process test.log which don't have action grouping, too
  # TODO: look if newrelic & Co. already does that but are only doing it for the last action
  # TODO: parse stack traces by grouping the lines by file and than method, generate a pseudo web sequence diagram code for files as participants and their methods
  # TODO: integrate a code snippet for each line of the stack trace like brakeman & co. do
  # TODO: extend rails stack trace output by code snippets
  def process_line(line)
    if line.match('Ctrl-C to shutdown server') && @start_after_last_shutdown
      reset_log
    elsif line.match('Processing') && line.match('#') && line.match(/\[/)  && line.match(/\]/)
      # rails 2 start of action
      # Processing Clickworker::DashboardsController#show (for 127.0.0.1 at 2011-08-26 12:22:58) [GET]
      @action = line.split(' ')[1]

      init_log_action
    #elsif line.match('Started') && line.match(' for ') && line.match(' at ') && line.split(' ').length == 9
      # rails 3 start of action
      # Started GET "/orders/815?truncate_length=1000" for 127.0.0.1 at 2011-10-04 19:58:44 +0200
    elsif line.match('Processing by') && line.match('#') && line.match(' as ') && line.split(' ').length == 5
      # rails 3 start of action
      # Processing by OrdersController#show as HTML
      @action = line.split(' ')[2]
      
      init_log_action
    elsif @action.blank?
    elsif line.match('Parameters:') && line.match('{') && line.match('}')
      line = line.split(' ')
      line.pop
      @log[@action]['Parameters'] = line.join(' ').strip
    elsif line.match('INSERT INTO') || line.match('UPDATE')
      table_name = table_name_from_line(line)
      
      data = line.match('INSERT INTO') ? process_insert(line) : process_update(table_name, line)
      
      # TaskTemplate Create (0.2ms)   INSERT INTO `task_templates` (`slug`, `name`, `created_at`, `product_id`, `updated_at`, `customer_id`, `state`) VALUES('the code', 'a customer name', '2011-08-26 10:22:54', 2, '2011-08-26 10:22:54', 1002, 'draft')
      #
      # InputDataItem Update (0.3ms)   UPDATE `data_items` SET `input` = '<opt>\n <input>\n <__dynamic_form__>\n <df_create>\n <the_input></the_input>\n <the_output>Output field 1</the_output>\n </df_create>\n </__dynamic_form__>\n </input>\n</opt>\n', `updated_at` = '2011-08-26 10:22:55' WHERE `id` = 5485
      

      @log[@action]['WRITE'][table_name] ||= { 'columns' => ['id'], 'rows' => [] }
      @writes[table_name] ||= { 'columns' => ['id'], 'rows' => [] }
      
      @log[@action]['WRITE'][table_name]['columns'] = @log[@action]['WRITE'][table_name]['columns'].concat(data.keys).uniq
      @writes[table_name]['columns'] = @writes[table_name]['columns'].concat(data.keys).uniq
      @log[@action]['WRITE'][table_name]['rows'] << data
      @writes[table_name]['rows'] << data
    elsif (line.match('Load') && line.match('SELECT')) || (line.match('CACHE') && line.match('\(') && line.match('ms\)'))
      line = line.split(')')
      line.shift
      @log[@action]['READ'] ||= []
      @log[@action]['READ'] << line.join(')').strip
    elsif line.match('Rendered') && line.match('\(') && line.match('ms\)')
      @log[@action]['Views'] ||= []
      line = line.split('Rendered')
      line.shift
      @log[@action]['Views'] << line.join('Rendered').split('(').first.strip
    elsif line.match('Rendering')
      @log[@action]['Views'] ||= []
      line = line.split('Rendering')
      line.shift
      @log[@action]['Views'] << line.join('').strip
    elsif (
      line.match('SHOW FIELDS FROM') || (line.match('SQL \(') && line.match('ms\)'))
    )
    else
      @log[@action]['misc'] << line
    end

    @last_action = @action
  end
  
  def table_name_from_line(line)
    line = line.split(')')
    line.shift
    line = line.join(')')

    line = line.split('`')
    line[1]
  end
  
  def process_insert(line)
    data = {}
    
    columns = line.match(/\(`(.)+\)(( |)VALUES)/)[0].split('VALUES').first.strip.gsub('`', '')[1..-2].split(',').map(&:strip)

    cells = nil
    
    #begin
      cells = line.match(/(VALUES(| )\()(.)+\)/)[0].split('VALUES').last.strip.
      gsub(/\('/, '(').
      gsub(/,(| )'/, ",").
      gsub(/',(| )'/, ",").
      gsub(/',(| )/, ",").
      strip[1..-2].split(',').map(&:strip)
    #rescue
    #  raise [line, line.match(/(VALUES(| )\()(.)+\)/)].inspect
    #end
    
    columns.each_index {|column_index| data[columns[column_index]] = cells[column_index]}
    
    data
  end
  
  def process_update(table_name, line)
    data = {}
    
    # SET `input` = '<opt>\n <input>\n <__dynamic_form__>\n <df_create>\n <the_input></the_input>\n <the_output>Output field 1</the_output>\n </df_create>\n </__dynamic_form__>\n </input>\n</opt>\n', `updated_at` = '2011-08-26 10:22:55' WHERE `id` = 5485
    line = line.split('WHERE')
    data_string = line.first
    conditions = line.last
    data_string = data_string.split(' '); data_string.shift; data_string = data_string.join(' ')
    data_string = data_string.gsub("', `", "||||").gsub(", `", '||||').gsub("` = '", "=").split('||||')

    data_string.each do |data_element|
      data_element = data_element.split('=')
      data[data_element.shift.gsub('`', '').strip] = data_element.join('=')
    end

    if conditions.match("`#{table_name}`.`id` = ([0-9]+)")
      data['id'] = conditions.match("`#{table_name}`.`id` = ([0-9]+)")[0].split('=').last.strip
    elsif conditions.match(/`id` = ([0-9]+)/)
      data['id'] = conditions.match(/`id` = ([0-9]+)/)[0].split('=').last.strip
    end

    data['WHERE'] = conditions
    
    data
  end
    
  def init_log_action
    if @action_indexes.has_key?(@action)
      @action_indexes[@action] = @action_indexes[@action] + 1
    else
      @action_indexes[@action] = 1
    end

    @action = "#{@action} ##{@action_indexes[@action]}"

    @log[@action] ||= { 'Parameters' => '', 'WRITE' => {}, 'READ' => [], 'views' => [], 'misc' => [], 'errors' => []}
  end
end