# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bixby-agent"
  s.version = "0.1.8"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Chetan Sarva"]
  s.date = "2013-02-02"
  s.description = "Bixby Agent"
  s.email = "chetan@pixelcop.net"
  s.executables = ["bixby-agent"]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "Rakefile",
    "VERSION",
    "bin/bixby-agent",
    "bixby-agent.gemspec",
    "lib/bixby-agent.rb",
    "lib/bixby_agent.rb",
    "lib/bixby_agent/agent.rb",
    "lib/bixby_agent/agent/config.rb",
    "lib/bixby_agent/agent/crypto.rb",
    "lib/bixby_agent/agent/handshake.rb",
    "lib/bixby_agent/agent/shell_exec.rb",
    "lib/bixby_agent/app.rb",
    "lib/bixby_agent/cli.rb",
    "lib/bixby_agent/config_exception.rb",
    "lib/bixby_agent/server.rb",
    "lib/bixby_agent/version.rb",
    "tasks/cane.rake",
    "tasks/jeweler.rake",
    "tasks/rcov.rake",
    "tasks/test.rake",
    "tasks/yard.rake",
    "test/base.rb",
    "test/helper.rb",
    "test/support/root_dir/bixby.yml",
    "test/support/root_dir/id_rsa",
    "test/support/root_dir/server",
    "test/support/root_dir/server.pub",
    "test/support/test_bundle/bin/cat",
    "test/support/test_bundle/bin/echo",
    "test/support/test_bundle/digest",
    "test/support/test_bundle/manifest.json",
    "test/test_agent.rb",
    "test/test_agent_exec.rb",
    "test/test_app.rb",
    "test/test_bixby_common.rb",
    "test/test_crypto.rb",
    "test/test_get_bundle.rb",
    "test/test_provisioning.rb",
    "test/test_server.rb"
  ]
  s.homepage = "http://github.com/chetan/bixby-agent"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Bixby Agent"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<bixby-common>, [">= 0"])
      s.add_runtime_dependency(%q<bixby-client>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, ["~> 1.3"])
      s.add_runtime_dependency(%q<thin>, [">= 0"])
      s.add_runtime_dependency(%q<api-auth>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_runtime_dependency(%q<oj>, [">= 0"])
      s.add_runtime_dependency(%q<httpi>, [">= 0"])
      s.add_runtime_dependency(%q<curb>, [">= 0"])
      s.add_runtime_dependency(%q<facter>, [">= 0"])
      s.add_runtime_dependency(%q<mixlib-cli>, [">= 0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_runtime_dependency(%q<uuidtools>, [">= 0"])
      s.add_runtime_dependency(%q<systemu>, [">= 0"])
      s.add_runtime_dependency(%q<logging>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<pry>, [">= 0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
      s.add_development_dependency(%q<guard>, [">= 0"])
      s.add_development_dependency(%q<colorize>, [">= 0"])
      s.add_development_dependency(%q<growl>, [">= 0"])
      s.add_development_dependency(%q<hirb>, [">= 0"])
      s.add_development_dependency(%q<bahia>, [">= 0"])
      s.add_development_dependency(%q<webmock>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<turn>, [">= 0"])
      s.add_development_dependency(%q<rack-test>, [">= 0"])
      s.add_development_dependency(%q<test_guard>, [">= 0"])
      s.add_development_dependency(%q<rb-inotify>, [">= 0"])
      s.add_development_dependency(%q<rb-fsevent>, [">= 0"])
      s.add_development_dependency(%q<rb-fchange>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<cane>, [">= 0"])
    else
      s.add_dependency(%q<bixby-common>, [">= 0"])
      s.add_dependency(%q<bixby-client>, [">= 0"])
      s.add_dependency(%q<sinatra>, ["~> 1.3"])
      s.add_dependency(%q<thin>, [">= 0"])
      s.add_dependency(%q<api-auth>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<oj>, [">= 0"])
      s.add_dependency(%q<httpi>, [">= 0"])
      s.add_dependency(%q<curb>, [">= 0"])
      s.add_dependency(%q<facter>, [">= 0"])
      s.add_dependency(%q<mixlib-cli>, [">= 0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<uuidtools>, [">= 0"])
      s.add_dependency(%q<systemu>, [">= 0"])
      s.add_dependency(%q<logging>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<pry>, [">= 0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<colorize>, [">= 0"])
      s.add_dependency(%q<growl>, [">= 0"])
      s.add_dependency(%q<hirb>, [">= 0"])
      s.add_dependency(%q<bahia>, [">= 0"])
      s.add_dependency(%q<webmock>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<turn>, [">= 0"])
      s.add_dependency(%q<rack-test>, [">= 0"])
      s.add_dependency(%q<test_guard>, [">= 0"])
      s.add_dependency(%q<rb-inotify>, [">= 0"])
      s.add_dependency(%q<rb-fsevent>, [">= 0"])
      s.add_dependency(%q<rb-fchange>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<cane>, [">= 0"])
    end
  else
    s.add_dependency(%q<bixby-common>, [">= 0"])
    s.add_dependency(%q<bixby-client>, [">= 0"])
    s.add_dependency(%q<sinatra>, ["~> 1.3"])
    s.add_dependency(%q<thin>, [">= 0"])
    s.add_dependency(%q<api-auth>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<oj>, [">= 0"])
    s.add_dependency(%q<httpi>, [">= 0"])
    s.add_dependency(%q<curb>, [">= 0"])
    s.add_dependency(%q<facter>, [">= 0"])
    s.add_dependency(%q<mixlib-cli>, [">= 0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<uuidtools>, [">= 0"])
    s.add_dependency(%q<systemu>, [">= 0"])
    s.add_dependency(%q<logging>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<pry>, [">= 0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<colorize>, [">= 0"])
    s.add_dependency(%q<growl>, [">= 0"])
    s.add_dependency(%q<hirb>, [">= 0"])
    s.add_dependency(%q<bahia>, [">= 0"])
    s.add_dependency(%q<webmock>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<turn>, [">= 0"])
    s.add_dependency(%q<rack-test>, [">= 0"])
    s.add_dependency(%q<test_guard>, [">= 0"])
    s.add_dependency(%q<rb-inotify>, [">= 0"])
    s.add_dependency(%q<rb-fsevent>, [">= 0"])
    s.add_dependency(%q<rb-fchange>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<cane>, [">= 0"])
  end
end

