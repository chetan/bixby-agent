
require 'jeweler'

Jeweler::Tasks.new do |gemspec|
  gemspec.name        = "bixby-agent"
  gemspec.summary     = "Bixby Agent"
  gemspec.description = "Bixby Agent"
  gemspec.email       = "chetan@pixelcop.net"
  gemspec.homepage    = "http://github.com/chetan/bixby-agent"
  gemspec.authors     = ["Chetan Sarva"]
  gemspec.license     = "MIT"

  gemspec.executables = %w{ bixby-agent }

  # exclude these bin scripts for now
  %w{ bin/bundle bin/cache_all.rb bin/install.sh bin/old_install.sh bin/package }.each do |f|
    gemspec.files.exclude f
  end

end
Jeweler::RubygemsDotOrgTasks.new
