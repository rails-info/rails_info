class RailsInfo::Logs::Test::Rspec::FilePresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    @name = options[:name]
    @tabs_data = options[:tabs_data]
    @index = options[:index] 
    @rails_root = options[:rails_root]
  end
       
  def tabs     
    html = content_tag :h3, link_to(@name, '#')
    
    html += content_tag(:div, class: 'tabs', id: "#{@name.parameterize}-tabs-#{@index}") do
      raw(navigation) + raw(body) 
    end
    
    html
  end
  
  private
  
  def navigation
    content_tag :ul do
      @tab_index = 0
      
      elements = ''
      
      @tabs_data.keys.select{|tab_key| tab_key.present?}.each do |tab_key| 
        elements += content_tag(
          :li, link_to(tab_key, "##{@name.parameterize}-tabs-#{@index}-#{@tab_index}")
        )
        @tab_index += 1
      end
      
      raw elements
    end
  end
  
  def body
    @tab_index, html = 0, ''
    
    @tabs_data.keys.select{|tab_key| tab_key.present?}.each do |tab_key|
      html += raw tab(tab_key)
    end
    
    html
  end

  def tab(tab_key)
    @content = @tabs_data[tab_key]
    
    content_tag :div, class: 'tabs', id: "#{@name.parameterize}-tabs-#{@index}-#{@tab_index}" do
      sub_content_tab
    end
  end
  
  def sub_content_tab
    content_tag :div, style: 'max-height:300px; overflow: auto' do
      attributes = []
      
      [:failure_code, :exception_class].each do |attribute|
        attributes << (content_tag(:strong, "#{attribute.to_s.humanize}: ") + h(@content[attribute]))
      end
      
      html = content_tag(:p, raw(attributes.join('&nbsp;&nbsp;|&nbsp;&nbsp;')))
      
      html += content_tag(:p) do
        content_tag(:strong, "#{:exception_message.to_s.humanize}: ") + 
        content_tag(:div, style: 'max-height:100px; overflow: auto') do
          raw(h(@content[:exception_message]).gsub('\n', '<br/>'))
        end
      end
      
      html += RailsInfo::StackTracePresenter.new(
        @subject, 
        stack_trace: { 
          body: @content[:stack_trace], rails_root: @rails_root, lines_of_code_around: 3 
        }
      ).accordion
      
      @tab_index += 1
 
      raw html
    end
  end
end