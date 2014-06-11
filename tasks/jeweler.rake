
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
  %w{ ci.sh ci_setup.sh install.sh }.each do |f|
    gemspec.files.exclude "bin/#{f}"
  end

end
Jeweler::RubygemsDotOrgTasks.new
