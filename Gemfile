source "http://rubygems.org"

gem "rails", "4.0.0"
gem "ocean", git: "git://github.com/OceanDev/ocean.git"

gem "jbuilder"

gem 'daemons'

gem "redis", "~> 3.0.1"          # Redis 
gem "hiredis", "~> 0.4.5"        # Optimise for speed

group :test, :development do
  gem "rspec-rails", "~> 2.0"
  gem "simplecov", :require => false
  gem "factory_girl_rails", "~> 4.0"
  gem "immigrant"
  gem "annotate", ">=2.5.0"
end

# Rails 3 compatibility
gem "protected_attributes"
gem "rails-observers"
