class RailsInfo::Logs::ServerController < RailsInfoController
  def new
    @rails_info_log = ::RailsInfo::Logs::ServerPresenter.new(view_context, log: params[:log], debug: params[:debug])
  end

  def update
    @rails_info_log = ::RailsInfo::Logs::ServerPresenter.new(view_context, log: params[:log], debug: params[:debug])
    render 'new'
  end
end