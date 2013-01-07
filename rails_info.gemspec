$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'rails_info/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rails_info'
  s.version     = RailsInfo::VERSION
  s.authors     = ['Mathias Gawlista']
  s.email       = ['gawlista@googlemail.com']
  s.homepage    = 'http://applicat.github.com/rails_info'
  s.summary     = 'Engine for a rails application which extends /rails/info about some information resources in development environment.'
  s.description = 'Engine for a rails application which extends /rails/info about some information resources in development environment.'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '>= 3.0'
  
  # assets
  s.add_dependency 'coffee-script'
  s.add_dependency 'uglifier'
  
  # view
  s.add_dependency 'jquery-rails'
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency 'pygments.rb'
  s.add_dependency 'twitter-bootstrap-rails'
  s.add_dependency 'simple-navigation-bootstrap'
  s.add_dependency 'therubyracer'
  s.add_dependency 'less-rails'
  
  s.add_development_dependency("awesome_print")
  s.add_development_dependency("rspec-rails")
  
  s.add_development_dependency 'mysql2'
end
