class RailsInfo::Logs::Server
  def initialize(options = {log: {}, debug: false})
    options ||= {log: {}, debug: false}
    options[:log] ||= {}
    
    @debug = options[:debug]
    rails_root = options[:log][:rails_root] || Rails.root.to_s
    env = options[:log][:env] || Rails.env
    @body = options[:log][:body] 
    @start_after_last_shutdown = options[:log][:start_after_last_shutdown] || true
    
    if @body.blank?
      file_path = "#{rails_root}/log/#{env}.log"
      
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
    @body = @body.split("\n").map{|l| l.gsub(/\e/, '')}.map(&:strip)

    reset_log
    group_by_action?
    
    @body.each do |line|
      process_line(line)
      @last_action = @action
    end

    delete_empty_tabs
    set_where_column_as_last_one_in_write_tab
    
    @body = nil # free memory
  end
  
  def reset_log
    @log, @action_indexes, @route, @action, @format, @last_action = {}, {}, '', '', '', ''
  end
  
  def group_by_action?
    group_by_action = false

    @body.each do |line|
      if line.match('Processing by') && line.match('#') && line.match(' as ') && line.split(' ').length == 5
        # rails 3
        group_by_action = true      
      #elsif line.match('Processing') && line.match('#') && line.match(/\[/)  && line.match(/\]/)
      # rails 2
      #  group_by_action = true
      #elsif line.match('Started') && line.match(' for ') && line.match(' at ') && line.split(' ').length == 9
      # rails 3
      #  group_by_action = true
        break
      end
    end

    unless group_by_action
      @action = 'no_action_grouping'
      @log[@action] ||= { 'Request' => {}, 'WRITE' => {}, 'READ' => [], 'views' => [], 'misc' => [], 'errors' => []}
    end
  end
  
  # TODO: process test.log which don't have action grouping, too
  # TODO: look if newrelic & Co. already does that but are only doing it for the last action
  # TODO: parse stack traces by grouping the lines by file and than method, generate a pseudo web sequence diagram code for files as participants and their methods
  # TODO: integrate a code snippet for each line of the stack trace like brakeman & co. do
  # TODO: extend rails stack trace output by code snippets
  def process_line(line)
    return if line.blank?
    
    reset_log and return if line.match('Ctrl-C to shutdown server') && @start_after_last_shutdown
    
    parse_route(line) and return
    
    return if @route.match(/"\/rails\/info.+"/)      
    
    parse_action(line) and return
    
    return if @action.blank?
    
    parse_request(line) and return
    parse_read(line) and return
    parse_write(line) and return
    
    if line.match('Rendered') && line.match('\(') && line.match('ms\)')
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
  end
  
  def delete_empty_tabs
    @log.each do |action,tabs|
      tabs.each do |tab,content|
        @log[action].delete(tab) if @log[action][tab].blank?
      end
    end
  end
  
  def set_where_column_as_last_one_in_write_tab
    @log.select{|a,t| t['WRITE'].is_a?(Hash) }.each do |action,tabs|
      tabs['WRITE'].each do |table_name,data|
        @log[action]['WRITE'][table_name]['columns'] << 'WHERE'
      end
    end
    
    @writes.each {|table_name,data| @writes[table_name]['columns'] << 'WHERE' }
  end
  
  def parse_route(line)
    reg_exp = /^Started(.{1,})for/
    
    return false unless line.match(reg_exp)
    
    @route = line.match(reg_exp)[1].strip
    
    true
  end
  
  def parse_action(line)
    reg_exp = /^Processing by {1}(.{1,}) {1}as {1}(.{1,})$/
    
    return false unless line.match(reg_exp)
    
    @action = line.match(reg_exp)[1].strip
    @format = line.match(reg_exp)[2].strip
    
    init_log_action unless @action.blank?
    
    true
  end
  
  def parse_request(line)
    reg_exp = /^Parameters:( ){1}(\{(.)+\}$)/
    
    if line.match(reg_exp)
      @log[@action]['Request']['Parameters'] = eval(line.match(reg_exp)[2]) rescue line
      
      true
    else
      false
    end
  end
  
  def parse_read(line)
    reg_exp_begin = '\[([0-9]+)m( {2}|)(SELECT.+)'
    
    #[1m[36mCommunity Load (0.5ms)[0m  [1mSELECT `communities`.* FROM `communities` WHERE `communities`.`id` = 2 LIMIT 1[0m   
    reg_exp1 = "#{reg_exp_begin}(\\[)"
    
    #[1m[35mCACHE (0.0ms)[0m  SELECT `communities`.* FROM `communities` WHERE `communities`.`deleted` = 0 AND `communities`.`slug` = 'bronze' LIMIT 1
    reg_exp2 = "#{reg_exp_begin}$"
    
    reg_exp = if line.match(reg_exp1)
      reg_exp1
    elsif line.match(reg_exp2)
      reg_exp2
    else
      nil
    end
    
    return false unless reg_exp
    
    @log[@action]['READ'] ||= [] 
    @log[@action]['READ'] << line.match(reg_exp)[3].strip
    
    true
  end
  
  def parse_write(line)
    begin_reg_exp = "\\[[0-9]+m *"
    reg_exp = "#{begin_reg_exp}((INSERT INTO|UPDATE|DELETE FROM)(.)+)$"
    
    return false unless line.match(reg_exp)
    
    table_name = line.match("(INSERT INTO|UPDATE|DELETE FROM) {1}`([a-zA-Z0-9_]+)`")[2]
    
    data = {}
    
    if line.match("#{begin_reg_exp}INSERT INTO( ){1}`(.{1,})`( ){1}(.)+$")
      data = process_insert(line)
    elsif line.match("#{begin_reg_exp}UPDATE( ){1}`(.{1,})`( ){1}(.)+$")
      data = process_update(table_name, line)
    elsif line.match("#{begin_reg_exp}DELETE FROM( ){1}`(.{1,})`( ){1}(.)+$")
      data = process_delete(table_name, line)
    else
      raise NotImplementedError
    end
    
    # TaskTemplate Create (0.2ms)   INSERT INTO `task_templates` (`slug`, `name`, `created_at`, `product_id`, `updated_at`, `customer_id`, `state`) VALUES('the code', 'a customer name', '2011-08-26 10:22:54', 2, '2011-08-26 10:22:54', 1002, 'draft')
    #
    # InputDataItem Update (0.3ms)   UPDATE `data_items` SET `input` = '<opt>\n <input>\n <__dynamic_form__>\n <df_create>\n <the_input></the_input>\n <the_output>Output field 1</the_output>\n </df_create>\n </__dynamic_form__>\n </input>\n</opt>\n', `updated_at` = '2011-08-26 10:22:55' WHERE `id` = 5485
    

    @log[@action]['WRITE'][table_name] ||= { 'columns' => ['-action-', 'id'], 'rows' => [] }
    @writes[table_name] ||= { 'columns' => ['-action-', 'id'], 'rows' => [] }
    
    @log[@action]['WRITE'][table_name]['columns'] = @log[@action]['WRITE'][table_name]['columns'].concat(data.keys).uniq
    @writes[table_name]['columns'] = @writes[table_name]['columns'].concat(data.keys).uniq
    @log[@action]['WRITE'][table_name]['rows'] << data
    @writes[table_name]['rows'] << data
    
    true
  end
  
  def process_insert(line)
    data = {'-action-' => 'INSERT'}
    
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
    data = {'-action-' => 'UPDATE'}
    
    #  "`editable` = 0, `updated_at` = '2012-07-09 16:33:31'"
    data_string = line.match(/SET (.+) WHERE/)[1].strip
    conditions = line.match(/WHERE(.+)$/)[1].strip
    
    data_string = data_string.gsub(/(', `|, `)/, "||||").gsub(/(` = '|` = )/, "=").gsub(/(`|')/, '').split('||||')
    
    data_string.each do |data_element|
      data_element = data_element.split('=')
      data[data_element.shift.strip] = data_element.join('=')
    end

    if conditions.match("`#{table_name}`.`id` = ([0-9]+)")
      data['id'] = conditions.match("`#{table_name}`.`id` = ([0-9]+)")[0].split('=').last.strip
    elsif conditions.match(/`id` = ([0-9]+)/)
      data['id'] = conditions.match(/`id` = ([0-9]+)/)[0].split('=').last.strip
    end

    data['WHERE'] = conditions
    
    data
  end
    
  def process_delete(table_name, line)
    data = {'-action-' => 'DELETE'}
    
    # ... WHERE `id` = 5485
    conditions = line.split('WHERE').last

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

    @log[@action] ||= { 'Request' => {'Route' => @route, 'Format' => @format}, 'WRITE' => {}, 'READ' => [], 'views' => [], 'misc' => [], 'errors' => []}
  end
end