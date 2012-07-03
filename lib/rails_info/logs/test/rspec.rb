class RailsInfo::Logs::Test::Rspec
  FILE_NAME_REGEXP = /[a-zA-Z]|[0-9]|\/|\.|_|-/
  
  def initialize(options = {log: {}, debug: false})
    options ||= {log: {}, debug: false}
    options[:log] ||= {}
    
    @rails_root = options[:log][:rails_root] || Rails.root.to_s
    @body = options[:log][:body]
    @show_all = options[:log][:show_all] || false
    @debug = options[:debug]
    
    unless @body
      file_path = "#{@rails_root}/log/rspec.log"
      
      @body = File.new(file_path, 'r').read if File.exist?(file_path)
    end
   
    @log ||= {}
    
    process if @body.present?
  end
  
  def summary
    @summary
  end
  
  def hash
    @log
  end
  
  def rails_root
    @rails_root
  end
  
  private
  
  def process
    @body = @body.split("\n").map(&:strip)
    
    failures_found, line_index = false, -1
    example, failure_code, exception_class, exception_message, stack_trace = nil, nil, nil, nil, []
    after_stack_trace_entry = nil
     
    @body.each do |line|
      line_index += 1
      
      if line.match('Failures:')
        failures_found = true
        
        next
      elsif line.match(/Finished in/) && @body[line_index + 1].match(/examples|failures|pending/)
        add_entry(example, failure_code, exception_class, exception_message, stack_trace, after_stack_trace_entry)
        
        @summary = @body[line_index + 1]
        
        break
      elsif line.blank?
        next
      end
      
      if failures_found && line.match(/^[0-9]+\)( ){1}([a-zA-Z]){1}/)  
        if example.present?
          add_entry(example, failure_code, exception_class, exception_message, stack_trace, after_stack_trace_entry)
        end
        
        after_stack_trace_entry, stack_trace = nil, []
         
        # 1) Community::CronJobs::Statistics.total_feedbacks_one_hour_ago principally works
        
=begin
        line = line.split(')').second.strip.split(' ')
        line.shift
        example = line.join(' ') # principally works
=end

        example = line.split(')').second.strip

        #Failure/Error: Feedback.make!(community: @community, user: @user)
        failure_code = @body[line_index + 1]
        #oMethodError:
        exception_class = @body[line_index + 2].split(':').first.strip
        
        if exception_class == 'expected' || @body[line_index + 3].split(':').first.strip == 'expected'
          #Reaction it should behave like objects that are 'hidable'#text_or_reason_for_hiding should return a notice if the entry has been hidden
          #Failure/Error: subject.content_or_reason_for_hiding.should == "Dieser Beitrag wurde am 2000-01-01 21:15:01 +0100 von Johann Wolfgang von Goethe gelöscht. Der Grund war: This entry sucks!"
          #expected: "Dieser Beitrag wurde am 2000-01-01 21:15:01 +0100 von Johann Wolfgang von Goethe gelöscht. Der Grund war: This entry sucks!"
          #got: "Dieser Beitrag wurde am 2000-01-01 20:15:01 +0000 von Johann Wolfgang von Goethe gelöscht. Der Grund war: This entry sucks!" (using ==)
          #Shared Example Group: "objects that are 'hidable'" called from ./spec/models/shared/hidable_trait_spec.rb:113
          ## ./spec/models/shared/hidable_trait_spec.rb:102:in `block (3 levels) in <top (required)>'
          exception_class, exception_message, after_stack_trace_entry = alternative_exception_message(line_index, 2..4)
        else
          #undefined method `moderators' for nil:NilClass
          exception_message = @body[line_index + 3]
        end
      elsif failures_found && line.match("^#( ){1}\.\/(#{FILE_NAME_REGEXP}){1,}:[0-9]{1,}:in( ){1}`((.){1,})'")  
        ## ./app/models/notification/email.rb:38:in `block in receivers'
        stack_trace << line
      end
    end
  end
  
  def add_entry(example, failure_code, exception_class, exception_message, stack_trace, after_stack_trace_entry = nil)
    stack_trace << after_stack_trace_entry if after_stack_trace_entry
    
    return unless stack_trace.any?
    
    # from spec line of code down to application line of code
    stack_trace.reverse!
    file_name = stack_trace.first.match("^#( ){1}(\.\/(#{FILE_NAME_REGEXP}){1,})")[2]
    
    @log[file_name] ||= {}
    
    if example.match(/\./) && example.split('.').length == 2 && !example.split('.').first.match(/ |'/)
      #Community::CronJobs::Statistics.total_feedbacks_one_hour_ago principally works
      example = ".#{example.split('.').second.strip}"
    elsif example.match(/#/) && example.split('#').length == 2 && !example.split('#').first.match(/ |'/)
      #Community::CronJobs::Statistics#total_feedbacks_one_hour_ago principally works  
      example = "##{example.split('#').second.strip}"
    elsif example.split(' ').length == 1
      #Reaction 
      #Failure/Error: it {should have_one(:spam_flag)}
      
      # make example unique by setting it to the failure code
      example = failure_code
    elsif example.split(' -').length == 2
      #Feedback -validations 
      #Failure/Error: it { should belong_to(:community) }
      
      # make example unique by including failure code
      example += " #{failure_code}"
    end
    
    if @log[file_name].has_key?(example)
      raise NotImplementedError.new(
        "RSpec file #{file_name} not expected to have more than 1 example named #{example.inspect}"
      )
    end

    @log[file_name][example] = {
      failure_code: failure_code, exception_class: exception_class, exception_message: exception_message, 
      stack_trace: stack_trace.join('\n')
    }
  end
  
  def alternative_exception_message(line_index, span)
    exception_class = '', after_stack_trace_entry = nil
    
    exception_message = span.to_a.map {|i| @body[line_index + i] }
          
    if exception_message.last.match("^(.){1,}( ){1}called from( ){1}\.(#{FILE_NAME_REGEXP}){1,}:([0-9]){1,}$")
      stack_trace_entry = exception_message.last.split('called from').last.strip
      after_stack_trace_entry = "# #{stack_trace_entry}:in `SORRY_BUT_NOT_PASSED_BY_RSPEC'"
    end
    
    exception_message = exception_message.join('\n')
    
    [exception_class, exception_message, after_stack_trace_entry]
  end
end