source 'https://rubygems.org'

gem 'bixby-common'
gem 'bixby-client'
# gem 'bixby-common', :path => "../common"
# gem 'bixby-client', :path => "../client"

gem 'sinatra', '~> 1.3'
gem 'thin'
gem 'api-auth', :git => "https://github.com/chetan/api_auth.git", :branch => "non_rails"
gem 'multi_json'
gem 'oj'
gem 'httpi',        :git => "https://github.com/chetan/httpi.git",
                    :branch => "chunked_responses"
gem 'curb'
gem 'facter'
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
    gem "bahia"
    gem 'webmock', :git => 'https://github.com/bblimke/webmock.git'
    gem 'mocha'
    gem "minitest"
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
