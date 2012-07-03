Rails.application.routes.draw do
  get '/rails/info' => 'rails_info/properties#index', as: 'rails_info'
  
  get '/rails/info/properties', to: 'rails_info/properties#index', as: 'rails_info_properties'
  get '/rails/info/routes', to: 'rails_info/routes#index', as: 'rails_info_routes'
  
  get '/rails/info/model', to: 'rails_info/model#index', as: 'rails_info_model'
  
  get '/rails/info/data', to: 'rails_info/data#index', as: 'rails_info_data', as: 'rails_info_data'
  post '/rails/info/data/update_multiple', to: 'rails_info/data#update_multiple', as: 'update_multiple_rails_info_data'
  
  get '/rails/info/logs/server' => 'rails_info/logs/server#new', as: 'new_rails_info_server_log'
  put '/rails/info/logs/server' => 'rails_info/logs/server#update', as: 'rails_info_server_log'
  
  get '/rails/info/logs/test/rspec' => 'rails_info/logs/test/rspec#new', as: 'new_rails_info_rspec_log'
  put '/rails/info/logs/test/rspec' => 'rails_info/logs/test/rspec#update', as: 'rails_info_rspec_log'
  
  get '/rails/info/stack_traces/new' => 'rails_info/stack_traces#new', as: 'new_rails_info_stack_trace'
  post '/rails/info/stack_traces' => 'rails_info/stack_traces#create', as: 'rails_info_stack_trace'
end
