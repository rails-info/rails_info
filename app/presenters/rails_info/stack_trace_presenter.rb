class RailsInfo::StackTracePresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    options[:stack_trace] ||= {}
    
    @stack_trace = ::RailsInfo::StackTrace.new(
      options[:stack_trace][:body], rails_root: options[:stack_trace][:rails_root], 
      request: options[:stack_trace][:request], exception: options[:stack_trace][:exception],
      show_all: options[:stack_trace][:show_all], lines_of_code_around: options[:stack_trace][:lines_of_code_around]
    )
  end
  
  def header
    html = ''
    
    if @stack_trace.exception
      html += content_tag(:h1, h(@stack_trace.title)) 
      html += content_tag(:pre, @stack_trace.message, class: 'stack_trace_message')
    end
    
    html += content_tag(:p, content_tag(:code, "Rails.root: #{rails_root}"))
    
    html
  end
  
  # Parameters
  #
  # type: full or application
  def accordion(type = 'full')
    content_tag :div, class: 'accordions' do
      html = ''
      
      hash = if type == 'application' 
        if @stack_trace.hash.keys.first.match(' of ') 
          @stack_trace.hash.select{|f,c| f.match("of #{rails_root}")}
        else
          @stack_trace.hash.select{|f,c| f.match(rails_root)}
        end
      else 
        @stack_trace.hash
      end
           
      hash.each do |file, code|
        file_without_rails_root = file.dup
       
        if file_without_rails_root.match(rails_root)
          file_without_rails_root.gsub!(rails_root, '') 
        end

        highligted_line_number = code[:highlighted_line_numbers].is_a?(Array) ? code[:highlighted_line_numbers].first : code[:highlighted_line_numbers]  
        link_to_line_number = link_to file_without_rails_root, "##{file_without_rails_root.parameterize}"
        html += content_tag :h3, raw("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#{file_without_rails_root}")
        code_presenter = ::RailsInfo::CodePresenter.new(@subject, code.merge(highlighted_number_name: file_without_rails_root))
        
        height = (((@stack_trace.lines_of_code_around * 2) + 1) * 18).round
        
        html += content_tag :div, raw(code_presenter.table), style: "max-height:#{height}px; overflow: auto"
      end  
      
      raw html
    end  
  end  
  
  def request_tab
    clean_params = request.filtered_parameters.clone
    clean_params.delete("action")
    clean_params.delete("controller")
  
    request_dump = clean_params.empty? ? 'None' : clean_params.inspect.gsub(',', ",\n")
    
    html = content_tag(:p) do
      content_tag(:strong, 'Parameters:') + content_tag(:pre, h(request_dump))
    end
    
    [:session, :env].each do |method|
      html += content_tag(:p) do
        link_to "Show #{method} dump", '#', onclick: "document.getElementById('#{method}_dump').style.display='block'; return false;"
      end
      
      html += content_tag(:div, id: "#{method}_dump", style: 'display:none') do
        content = method == :env ? request.env.slice(*request.class::ENV_METHODS) : request.send(method) 
        content_tag :pre, debug_hash(content)
      end 
    end
    
    html
  end
  
  def response_tab
    content_tag :p do
      content_tag(:strong, 'Headers:') + content_tag(:pre, h(defined?(@response) ? response.headers.inspect.gsub(',', ",\n") : 'None'))
    end
  end
  
  private
  
  def rails_root
    if @stack_trace.rails_root
      @stack_trace.rails_root
    elsif defined?(Rails) && Rails.respond_to?(:root) 
      Rails.root.to_s
    else
      'unset'
    end
  end
  
  def debug_hash(hash)
    hash.sort_by { |k, v| k.to_s }.map { |k, v| "#{k}: #{v.inspect rescue $!.message}" }.join("\n")
  end
end