class RailsInfo::Logs::Test::RspecController < RailsInfoController
  layout 'rails_info/exception'
  
  def new
    @rails_info_log = ::RailsInfo::Logs::Test::RspecPresenter.new(
      view_context, log: {rails_root: Rails.root.to_s}.merge(params[:log] || {}), debug: params[:debug] 
    )
  end

  def update
    @rails_info_log = ::RailsInfo::Logs::Test::RspecPresenter.new(
      view_context, log: params[:log], debug: params[:debug]
    )
    render 'new'
  end
end