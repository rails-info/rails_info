module RailsInfo::FormHelper
  def rails_info_field(name, options = {})
    error = @filter.errors[name]
    hint = options.delete(:hint)
    
    content_tag :div, class: 'control-group' + (error ? ' error' : '') do
      content = []
      
      content << label_tag("filter[#{name}]", name.humanize, class: 'control-label')
      
      content << content_tag(:div, class: 'controls') do
        controls = []
         
        unless block_given? 
          controls << text_field_tag("filter[#{name}]", @filter.send(name), options)
        end
        
        controls << content_tag(:p, hint, class: 'help-block') if hint
        controls << content_tag(:span, error, class: 'help-inline') if error
        
        controls = controls.join(' ')
        
        if block_given?
          yield(name, controls)
        else
          raw controls
        end
      end
      
      raw content.join(' ')
    end
  end
  
  def short_path(path, setting)
    begin
      path.gsub(setting[:paths].select{|part| path.match(part) }.first, '')
    rescue TypeError
      raise [path, setting[:paths]].inspect
    end
  end
end