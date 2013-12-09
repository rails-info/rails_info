class RailsInfo::Logs::ServerController < RailsInfoController
  def new
    @rails_info_log = ::RailsInfo::Logs::ServerPresenter.new(view_context, log: params[:log], debug: params[:debug])
  end

  def update
    @rails_info_log = ::RailsInfo::Logs::ServerPresenter.new(view_context, log: params[:log], debug: params[:debug])
    render 'new'
  end
  
  def big
    @requests = []
    
    open('/Users/gawlim/workspace/mtvnn-sensei/log/production.log').read.split("\n").each do |line|
      if line.match('Started GET') && line.match('freewheel')
        @requests << line
      end
    end
  end
end