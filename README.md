# RailsInfo

Experimental engine for a rails application besides admin and continous integration web interface which extends standard /rails/info (properties through public.html iframe and on Rails 3 Edge / Rails 4 also the routes action) about some extra information resources in development environment.

## Installation

### Mount in existing Rails application or ...

TODO

### Use as separate Rails application

Clone and install [rails_info_application](http://GitHub.com/rails-info/rails_info_application)

## [Modules](https://github.com/rails-info/rails_info/wiki/modules)

## Caveats

Prepare for sporadic Ruby segmentation faults caused by the Python powered syntax highlighter pygments in the early stages of this project (at least under Ruby 1.9.3 & Rails 3.2.6 on MacOS). 
There will be a configuration option for deactivating syntax highlighting soon for the time being without a solution for this problem.

Tested on MacOS with: Ruby 2.2.0 & Rails 4.2.0

## Contribution

Just follow the [screencast of Ryan Bates on railscasts.com](http://railscasts.com/episodes/300-contributing-to-open-source): 

Add a description about your changes to CHANGELOG.md under top section rails_info (unreleased).

## License 

This project uses MIT-LICENSE.
