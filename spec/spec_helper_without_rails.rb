unless defined? Rails
  class Rails
    def self.root
      File.expand_path('dummy', __FILE__)
    end
    
    def self.env
      'test'
    end
  end
end

ENV["RAILS_ENV"] ||= 'test'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
end

# https://makandracards.com/makandra/950-speed-up-rspec-by-deferring-garbage-collection
RSpec.configure do |config|
  config.before(:all) do
    DeferredGarbageCollection.start
  end
  config.after(:all) do
    DeferredGarbageCollection.reconsider 
  end
end