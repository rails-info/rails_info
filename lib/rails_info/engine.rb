module RailsInfo
  class Engine < ::Rails::Engine  
   config.before_initialize do |app|
      if Rails.env.development? || Rails.env.test?
        SimpleNavigation.config_file_paths << "#{File.expand_path(File.dirname(__FILE__))}/../../config"
      end
    end
  end
end
