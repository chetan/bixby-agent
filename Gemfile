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

    # deprecated webserver
    gem 'sinatra', '~> 1.3'
    gem 'puma'

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
    gem "bahia"
    gem 'webmock'
    gem 'mocha'
    gem "minitest", "~> 4.7"
    gem "turn"

    gem "rack-test"

    # tools
    gem "test_guard", :git => "https://github.com/chetan/test_guard.git"
    gem 'rb-inotify', :require => false
    gem 'rb-fsevent', :require => false
    gem 'rb-fchange', :require => false

    # coverage
    gem "simplecov",:platforms => :mri_19
    gem "rcov", :platforms => :mri_18

    # quality
    gem "cane", :platforms => :mri_19
end
