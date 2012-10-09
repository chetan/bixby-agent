source 'http://rubygems.org'

gem 'bixby-common', :git => "https://github.com/chetan/bixby-common.git"

gem 'sinatra', '~> 1.3'
gem 'thin'
gem 'multi_json'
gem 'oj'
gem 'curb'
gem 'facter'
gem 'mixlib-cli'
gem 'uuidtools'
gem 'systemu'
gem 'logging'

group :development, :test do

    # packaging
    gem 'jeweler', '~> 1.8.3'
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
    gem 'rb-fsevent', '~> 0.9.1' if RbConfig::CONFIG['target_os'] =~ /darwin(1.+)?$/i
    gem 'rb-inotify', '~> 0.8.8', :github => 'mbj/rb-inotify' if RbConfig::CONFIG['target_os'] =~ /linux/i
    gem 'wdm',        '~> 0.0.3' if RbConfig::CONFIG['target_os'] =~ /mswin|mingw/i

    # coverage
    gem "simplecov",:platforms => :mri_19
    gem "rcov", :platforms => :mri_18

    # quality
    gem "cane", :platforms => :mri_19
end
