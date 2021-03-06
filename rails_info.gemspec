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
  
  s.add_dependency 'grit'
  
  # assets
  s.add_dependency 'coffee-script'
  s.add_dependency 'uglifier'
  
  # view
  s.add_dependency 'sass-rails', '~> 3.2'
  s.add_dependency 'bootstrap-sass', '~> 2.3.1.0'
  s.add_dependency 'mustache', '~> 0.99.4'
  s.add_dependency 'simple-navigation-bootstrap', '~> 0.0.4'
  s.add_dependency 'jquery-rails', '~> 2.2.1'
  s.add_dependency 'jquery-ui-rails', '~> 4.0.2'
  s.add_dependency 'diff_to_html', '~> 0.0.1'
  s.add_dependency 'pygments.rb', '~> 0.5.0'
  s.add_dependency 'therubyracer', '~> 0.11.4'
  
  s.add_development_dependency 'awesome_print', '~> 1.1.0'
  s.add_development_dependency 'rspec-rails', '~> 2.13.1'
  
  s.add_development_dependency 'mysql2', '~> 0.3.11'
end
