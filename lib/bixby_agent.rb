
# try to detect dev env
path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
if File.directory? File.join(path, ".git") then
  ENV["BIXBY_HOME"] = path if not ENV["BIXBY_HOME"]
  require "bundler/setup"
end

require "bixby_common"
require "bixby-client"

require "bixby_agent/agent"
require "bixby_agent/version"

Bixby::Agent.setup_env()
