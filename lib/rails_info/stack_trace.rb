class RailsInfo::StackTrace
  def initialize(stack_trace, options = {})
    @request = options[:request]
    @exception = options[:exception]
    @rails_root = options[:rails_root] || Rails.root.to_s
    @lines_of_code_around = options[:lines_of_code_around] || 5
    @show_all = options[:show_all]
    
    if stack_trace.is_a?(String) && stack_trace.match('#')
      # parse RSpec style stack trace "# ./app/observers/assignment_observer.rb:65:in `after_save'"
      line_separator = if stack_trace.match(/\r\n/) 
        "\r\n"
      elsif stack_trace.match(/\\n/)
        /\\n/
      else 
        "\n"
      end
      
      stack_trace = stack_trace.split(line_separator).map{|line|line.gsub('#', '').gsub('./', rails_root + '/')}.map(&:strip)
    elsif stack_trace.is_a?(String) && !stack_trace.strip.blank?
      raise NotImplementedError.new(stack_trace.inspect)
    end
    
    @stack_trace = stack_trace
  end
  
  def exception
    @exception
  end
  
  def title
    text = @exception.class.to_s
    
    if @request && @request.parameters['controller']
      action = @request.parameters['action'].present? ? "##{@request.parameters['action']}" : ''
      text += " in #{@request.parameters['controller'].camelize}Controller#{action}"
    end
    
    text
  end
  
  def message
    @exception.message
  end
  
  def lines_of_code_around
    @lines_of_code_around
  end
  
  def hash
    return @hash if @hash
    
    @hash = {}
    
    parse_stack_trace
    
    @hash
  end
  
  def request
    @request
  end
  
  def response
    @response
  end
  
  def rails_root
    @rails_root
  end
  
  private
  
  def parse_stack_trace
    (@stack_trace.is_a?(Array) ? @stack_trace : []).each{|line| parse_stack_trace_line(line) }
  end
  
  # TODO: add additionally tab with a diff of separate rails_root / gemset when those parameters have been passed
  def parse_stack_trace_line(line_string)
    line = {}
    
    if line_string.match(/in `((.)+)'/)
      method = line_string.match(/in `((.)+)'/)[1]
      
      line_string.gsub!(method, '')
      line = line_string.split(':')
      line = {file: line.first.strip, number: line.second.strip.to_i}
    elsif line_string.match(/at(.+|) \(((.)+)\)/)
      # at less.Parser.parser.parse.i (/Users/gawlim/.rvm/gems/ruby-1.9.3-p327@mtvnn-sensei_shadow/gems/less-2.2.2/lib/less/js/lib/less/parser.js:385:31)
      # at (/Users/gawlim/.rvm/gems/ruby-1.9.3-p327@mtvnn-sensei_shadow/gems/less-2.2.2/lib/less/js/lib/less/parser.js:385:31)
      method = line_string.match(/at(.+|) \(((.)+)\)/)[1]
      line = line_string.match(/at(.+|) \(((.)+)\)/)[2].split(':')
      
      line = {file: line.first.strip, number: line.second.strip.to_i}
    else
      raise NotImplementedError  
    end
    
    code = {}
    
    if File.exist? line[:file]
      code = code_with_line_numbers(line)
    else
      code = { text: "File #{line[:file]} not found", line_numbers: [0]}
    end
    
    path = line[:file].split('/')
    file_name = path.pop
    
    @hash["#{method} @ #{line[:number]} in #{file_name} of #{path.join('/')}"] = code
 end
 
 def code_with_line_numbers(options = {})
    options.assert_valid_keys(:file, :number)
    
    middle_number = options[:number]
    
    lines_hash, current_number = {}, 0
    
    File.open options[:file] do |f|
      f.each_line do |line|
        current_number += 1

        next if line.strip == "" # remove empty lines

        lines_hash[current_number] = line
      end
    end
    
    not_empty_index, middle_index = 0, 0
    
    unless lines_hash.keys.include?(middle_number)
      alternative_middle_numbers = lines_hash.keys.select{|number| number >= middle_number - @lines_of_code_around && number <= middle_number + @lines_of_code_around }
      
      if alternative_middle_numbers
        middle_number = alternative_middle_numbers[(alternative_middle_numbers.length / 2).round - 1]
      else
        middle_number = nil
      end
    end
    
    lines_hash.each do |number,line| 
      middle_index = not_empty_index if number == middle_number
      not_empty_index += 1
    end
    
    not_empty_index, lines, line_numbers = -1, [], []
    highlighted_number, visible_number = nil, 1
    
    lines_hash.each do |number,line|
      not_empty_index += 1
      
      unless @show_all || middle_number.nil?
        next unless not_empty_index >= middle_index - @lines_of_code_around && not_empty_index <= middle_index + @lines_of_code_around
      end
        
      lines << line
      line_numbers << number
      highlighted_number = visible_number if middle_number && number == middle_number
      visible_number += 1
    end
    
    # try to free memory
    lines_hash = nil
    
    { text: lines.join(''), number: options[:number], line_numbers: line_numbers, highlighted_line_numbers: [highlighted_number] }
  end
end