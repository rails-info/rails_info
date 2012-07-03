SimpleNavigation::Configuration.run do |navigation|  
  navigation.items do |primary|
    primary.dom_class = 'nav'
    primary.item :root, 'Index', rails_info_path
    primary.item :properties, 'Properties', rails_info_properties_path
    primary.item :routes, 'Routes', rails_info_routes_path
  
    primary.item :model, 'Model', rails_info_model_path do |model|
      model.item :model_index, 'Index', rails_info_model_path
      model.item :data, 'Data', rails_info_data_path
    end
    
    primary.item :logs, 'Logs', '#logs' do |logs|
      logs.item :server, 'Server', new_rails_info_server_log_path
      logs.item :rspec, 'Test > RSpec', new_rails_info_rspec_log_path
    end
    
    primary.item :stack_traces, 'Stack Traces', new_rails_info_stack_trace_path
  end
end