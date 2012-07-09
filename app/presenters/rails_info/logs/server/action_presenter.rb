class RailsInfo::Logs::Server::ActionPresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    @name = options[:name]
    @tabs_data = options[:tabs_data]
    @index = options[:index] 
  end
       
  def tabs     
    html = content_tag :h3, link_to(@name, '#')
    
    html += content_tag(:div, class: 'tabs', id: "tabs-#{@index}") do
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
        elements += content_tag :li, link_to(tab_key, "#tabs-#{@index}-#{@tab_index}")
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
    
    content_tag :div, class: 'tabs', id: "tabs-#{@index}-#{@tab_index}" do
      html = if tab_key == 'Request'
        raw render partial: 'rails_info/logs/server/request', locals: { content: @content }
      else
        raw @content.is_a?(Hash) ? sub_tabs : sub_content_tab
      end
      
      @tab_index += 1
      
      html
    end
  end
  
  def sub_tabs
    html = ''
    
    html += content_tag :div, class: 'tabs', id: "tabs-#{@index}-#{@tab_index}-subtabs" do
      raw(sub_navigation) + raw(sub_body)
    end
    
    html
  end
  
  def sub_content_tab
    content_tag :div, style: 'max-height:400px; width:100%; overflow: auto' do
      if @content.is_a?(Array) 
        @content.map!{|c| CGI.escapeHTML(c) }
        @content = @content.join('<br/><br/>')
      else
        @content = CGI.escapeHTML(@content) 
      end
 
      raw @content
    end
  end
  
  def sub_navigation
    sub_tab_index = 0
    
    content_tag :ul do
      elements = ''
      
      @content.keys.map(&:to_s).select{|tab_key| tab_key.present? }.each do |tab_key|
        elements += content_tag :li, link_to(tab_key, "#tabs-#{@index}-#{@tab_index}-#{sub_tab_index}")
        sub_tab_index += 1 
      end
      
      raw elements
    end
  end
  
  def sub_body
    html, sub_tab_index = '', 0
    
    @content.keys.map(&:to_s).select{|tab| tab.present? }.each do |tab|
      sub_content = @content[tab]
      
      html += content_tag :div, class: 'tabs', id: "tabs-#{@index}-#{@tab_index}-#{sub_tab_index}" do
        sub_tab_index += 1
        
        raw render partial: 'rails_info/logs/server/table', locals: { sub_content: sub_content }
      end
    end
    
    html
  end
end