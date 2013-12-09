module ActionDispatch::Routing
  class Mapper
    # Includes mount_sextant method for routes. This method is responsible to
    # generate all needed routes for sextant
    def mount_rails_info
      match '/rails/info' => 'rails_info/properties#index', via: :get, via: :get, as: 'rails_info'
  
      match '/rails/info/properties' => 'rails_info/properties#index', via: :get, via: :get, as: 'rails_info_properties'
      match '/rails/info/routes' => 'rails_info/routes#index', via: :get, as: 'rails_info_routes'
      
      match '/rails/info/model' => 'rails_info/model#index', via: :get, as: 'rails_info_model'
      
      match '/rails/info/data' => 'rails_info/data#index', via: :get, as: 'rails_info_data', via: :get, as: 'rails_info_data'
      post '/rails/info/data/update_multiple' => 'rails_info/data#update_multiple', via: :post, as: 'rails_update_multiple_rails_info_data'
      
      match '/rails/info/logs/server' => 'rails_info/logs/server#new', via: :get, as: 'new_rails_info_server_log'
      put '/rails/info/logs/server' => 'rails_info/logs/server#update', via: :put, as: 'rails_info_server_log'
      
      get '/rails/info/logs/server/big' => 'rails_info/logs/server#big'
      
      match '/rails/info/logs/test/rspec' => 'rails_info/logs/test/rspec#new', via: :get, as: 'new_rails_info_rspec_log'
      put '/rails/info/logs/test/rspec' => 'rails_info/logs/test/rspec#update', via: :put, as: 'rails_info_rspec_log'
      
      match '/rails/info/stack_traces/new' => 'rails_info/stack_traces#new', via: :get, as: 'new_rails_info_stack_trace'
      post '/rails/info/stack_traces' => 'rails_info/stack_traces#create', via: :post, as: 'rails_info_stack_trace'
      
      namespace 'rails_info', path: 'rails/info' do
        namespace 'system' do
          resources :directories, only: :index
        end
        
        namespace 'version_control' do
          resources :filters, only: [:new, :create]
          
          resources :diffs, only: :new
        end
      end
    end
  end
end

