class RailsInfoController < Rails::InfoController
  before_filter :check_if_all_requests_local
  helper RailsInfo::Engine.helpers
  
  #TODO: should inherit from ApplicationController especially for authentification & authorization purposes
  layout 'rails_info'
  
  private

  def check_if_all_requests_local
    unless Rails.application.config.consider_all_requests_local || request.local?
      render text: '<p>For security purposes, this information is only available to local requests.</p>', status: :forbidden
    end
  end
end
