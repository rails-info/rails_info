class RailsInfo::Logs::ServerPresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    @rails_info_log = ::RailsInfo::Logs::Server.new(log: params[:log], debug: params[:debug])
  end
  
  def accordion
    @action_index = 0
    
    content_tag :div, id: 'actions', class: 'accordions' do
      html = ''
      
      @rails_info_log.hash.each do |action, tabs|
        action_presenter = ::RailsInfo::Logs::Server::ActionPresenter.new(
          @subject, name: action, tabs_data: tabs, index: @action_index
        )
        @action_index += 1
        html += raw action_presenter.tabs
      end  
      
      raw html
    end  
  end
  
  def write_tabs
    content_tag :div, class: 'tabs', id: 'writes' do
      write_navigation
      write_body
    end
  end
  
  def write_navigation
    tab_index = 0
    
    content_tag :ul do
      @rails_info_log.writes.each do |table_name,data|
        li = content_tag :li, link_to(table_name, "writes-#{tab_index}")
        
        tab_index += 1
        
        li
      end
    end
  end
  
  def write_body
    tab_index = 0
    
    @rails_info_log.writes.each do |table_name,data|
      content_tag :div, class: 'tabs', id: "writes-#{tab_index}" do
        tab_index += 1
        render partial: 'table', locals: { sub_content: data }
      end
    end
  end
end