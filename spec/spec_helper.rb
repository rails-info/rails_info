require 'rubygems'

require File.expand_path("../dummy/config/environment.rb",  __FILE__) unless defined?(Rails)

require File.expand_path("../spec_helper_without_rails", __FILE__)

require 'rspec/rails'