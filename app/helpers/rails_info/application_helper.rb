module RailsInfo::ApplicationHelper
  def rails_info_stylesheet
    if controller.send(:_layout) == 'rails_info'
      'rails_info/application'
    elsif controller.send(:_layout).is_a?(String) && controller.send(:_layout).match('rails_info') 
      controller.send(:_layout)
    else 
      'rails_info/exception'
    end
  end
end