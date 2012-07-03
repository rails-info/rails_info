class RailsInfo::Logs::Test::RspecPresenter < ::RailsInfo::Presenter
  def initialize(subject, options = {})
    super(subject, options)
    
    @rails_info_log = ::RailsInfo::Logs::Test::Rspec.new(
      log: options[:log], debug: options[:debug]
    )
  end
  
  def summary
    content_tag :p, "#{@rails_info_log.hash.keys.length} files, #{@rails_info_log.summary}"
  end
  
  def accordion
    @index = 0
    
    content_tag :div, id: 'files', class: 'accordions' do
      html = ''
      
      @rails_info_log.hash.each do |file, examples|
        file_presenter = ::RailsInfo::Logs::Test::Rspec::FilePresenter.new(
          @subject, name: "#{file} (#{examples.length})", 
          tabs_data: examples, index: @index, rails_root: @rails_info_log.rails_root
        )
        @index += 1
        html += raw file_presenter.tabs
      end  
      
      raw html
    end  
  end
end