class RailsInfo::RoutesController < RailsInfoController
  def index
    @rails_info_routes = ::RailsInfo::RoutesPresenter.new(view_context)
  end
end