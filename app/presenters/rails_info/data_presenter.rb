class RailsInfo::DataPresenter < ::RailsInfo::Presenter
  def actions
    content_tag :div, submit_tag(I18n.t('rails_info.data.general.delete'), name: 'delete')
  end
  
  def last_objects
    return @last_objects if @last_objects
    
    @last_objects = ::RailsInfo::Data.new.last_objects
    
    if @last_objects.flatten.none?
      I18n.t('rails_info.data.index.no_models_found')
    else
      @last_objects.map{|row_set| ::RailsInfo::Data::RowSetPresenter.new(subject, row_set: row_set) }.each do |row_set_presenter|
        yield row_set_presenter
      end
      
      ""
    end
  end
end