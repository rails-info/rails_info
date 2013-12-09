module RailsInfo::Controller::ExceptionDiagnostics
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :custom_stack_trace
  end

  private
  
  def custom_stack_trace(exception)  
    if Rails.env.development?
      @stack_trace = RailsInfo::StackTracePresenter.new(
        view_context, stack_trace: { 
          body: exception.backtrace, exception: exception , request: request
        }  
      )
      
      render 'rails_info/stack_traces/new', layout: 'rails_info/exception'
    else
      raise exception
    end
  end
end