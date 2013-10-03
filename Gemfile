source 'https://rubygems.org'

gem 'bixby-common'
gem 'bixby-client'
# gem 'bixby-common', :path => "../common"
# gem 'bixby-client', :path => "../client"

gem 'god'
gem 'daemons'
gem 'api-auth', :git => "https://github.com/chetan/api_auth.git", :branch => "bixby"
gem 'multi_json'
gem 'oj'
gem 'httpi'
gem 'curb'
gem 'facter', '~> 1.6.0'
gem 'mixlib-cli'
gem 'mixlib-shellout'
gem 'highline'
gem 'uuidtools'
gem 'logging'

group :development, :test do

    # packaging
    gem 'jeweler', :git => "https://github.com/chetan/jeweler.git", :branch => "bixby"
    gem 'yard', '~> 0.7'

    # debugging
    gem 'pry'
    gem 'awesome_print'
    gem 'guard'
    gem 'colorize'
    gem 'growl'
    gem 'hirb'

    # test frameworks
    gem "bahia",   :require => false
    gem 'webmock', :require => false
    gem 'mocha',   :require => false

    # tools
    gem "micron", :github => "chetan/micron"
    gem "test_guard", :git => "https://github.com/chetan/test_guard.git"
    gem 'rb-inotify', :require => false
    gem 'rb-fsevent', :require => false
    gem 'rb-fchange', :require => false

    # coverage
    gem "simplecov",:platforms => [:mri_19, :mri_20]

    # quality
    gem "cane", :platforms => [:mri_19, :mri_20]
end
