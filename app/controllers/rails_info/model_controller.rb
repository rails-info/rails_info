class RailsInfo::ModelController < RailsInfoController
  def index
    @rails_info_model = ::RailsInfo::ModelPresenter.new(view_context)
  end
end