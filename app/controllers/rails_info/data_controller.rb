class RailsInfo::DataController < RailsInfoController
  def index
    @rails_info_data = ::RailsInfo::DataPresenter.new(view_context)
  end

  def update_multiple_data
    RailsInfo::Data.update_multiple_data(params[:data]) if params[:delete]
  end
end