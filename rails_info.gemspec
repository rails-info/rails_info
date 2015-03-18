$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'rails_info/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'rails_info'
  s.version     = RailsInfo::VERSION
  s.authors     = ['Mathias Gawlista']
  s.email       = ['gawlista@gmail.com']
  s.homepage    = 'http://GitHub.com/rails-info/rails_info'
  s.summary     = 'Rails #engine which extends /rails/info about some further routes for more insights.'
  s.description = 'extends /#rails/info about some further routes'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 4.2.0'

  s.add_development_dependency 'sqlite3', '~> 1.3.10'
  s.add_development_dependency 'home_page', 'home_page', '~> 0.0.6'
end
