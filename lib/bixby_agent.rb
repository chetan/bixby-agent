
# try to detect dev env
path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
if File.directory? File.join(path, ".git") then
  ENV["BIXBY_HOME"] = path
  require "bundler/setup"
end

require "bixby_common"

require 'bixby_agent/model/bundle_command'
require "bixby_agent/agent"
require "bixby_agent/version"

Bixby::Agent.setup_env()
