source 'https://rubygems.org'

group :self do
  gem 'bixby-agent', :path => "."
end

gem 'bixby-common', "~> 0.6"
gem 'bixby-client', "~> 0.5"
gem 'bixby-auth', "~> 0.1"
#gem 'bixby-auth',   :path => "../auth"
#gem 'bixby-common', :path => "../common"
#gem 'bixby-client', :path => "../client"

gem 'god', "~> 0.13"
gem 'daemons', "~> 1.1"
gem 'multi_json', "~> 1.8"
gem 'oj', "~> 2.11"
gem 'httpi', "~> 2.3"
gem 'facter', '~> 2.0.0'
gem 'mixlib-cli', "~> 1.5"
gem 'mixlib-shellout', "~> 2.0"
gem 'uuidtools', "~> 2.1"
gem 'logging', "~> 1.8"

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
  gem "cane", :platforms => [:mri_19, :mri_20, :mri_21, :mri_22]
end

group :development, :test do
  # packaging
  gem "rake"
  gem 'jeweler', :github => "chetan/jeweler", :branch => "bixby"

  # test frameworks
  gem 'webmock', :require => false
  gem 'mocha',   :require => false

  # tools
  gem "simplecov", :platforms => [:mri_19, :mri_20, :mri_21, :mri_22]
  gem "coveralls", :require => false
  gem "micron", :github => "chetan/micron"
  gem 'rb-inotify', :require => false
  gem 'rb-fsevent', :require => false
  gem 'rb-fchange', :require => false
end
