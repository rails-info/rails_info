module RailsInfo::Controller::ExceptionDiagnostics
  extend ActiveSupport::Concern

  included do
    rescue_from Exception, with: :custom_stack_trace
  end

  private
  
  def custom_stack_trace(exception) 
=begin    
    wrapper = ActionDispatch::ExceptionWrapper.new(env, exception)
    trace = {
      exception: wrapper.exception,
      :application_trace => wrapper.application_trace,
      :framework_trace => wrapper.framework_trace,
      :full_trace => wrapper.full_trace
    }      
=end
    @stack_trace = RailsInfo::StackTracePresenter.new(
      view_context, stack_trace: { 
        body: exception.backtrace, exception: exception , request: request
      }  
    )
    
    render 'rails_info/stack_traces/new', layout: 'rails_info/exception'
  end
end