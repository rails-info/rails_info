class RailsInfo::StackTracesController < RailsInfoController
  layout 'rails_info/exception'
  
  def new
  end
  
  def create
    @stack_trace = RailsInfo::StackTracePresenter.new(view_context, stack_trace: params[:stack_trace])
    render 'new'
  end
end