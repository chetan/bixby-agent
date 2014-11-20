source 'https://rubygems.org'

group :self do
  gem 'bixby-agent', :path => "."
end

gem 'bixby-common'
gem 'bixby-client'
gem 'bixby-auth'
#gem 'bixby-auth',   :path => "../auth"
#gem 'bixby-common', :path => "../common"
#gem 'bixby-client', :path => "../client"

gem 'god'
gem 'daemons'
gem 'multi_json'
gem 'oj'
gem 'httpi'
gem 'curb'
gem 'facter', '~> 2.0.0'
gem 'mixlib-cli'
gem 'mixlib-shellout'
gem 'highline'
gem 'uuidtools'
gem 'logging'

group :development do
  # packaging
  gem 'yard', '~> 0.7'

  # debugging
  gem 'pry'
  gem 'awesome_print'
  gem 'colorize'
  gem 'growl'
  gem 'hirb'

  # tools
  gem "test_guard", :github => "chetan/test_guard"

  # quality
  gem "cane", :platforms => [:mri_19, :mri_20]
end

group :development, :test do
  # packaging
  gem "rake"
  gem 'jeweler', :github => "chetan/jeweler", :branch => "bixby"

  # test frameworks
  gem 'webmock', :require => false
  gem 'mocha',   :require => false

  # tools
  gem "simplecov", :platforms => [:mri_19, :mri_20]
  gem "coveralls", :require => false
  gem "micron", :github => "chetan/micron"
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end
