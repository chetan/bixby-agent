
# try to detect dev env
path = File.expand_path(File.join(File.dirname(__FILE__), ".."))

if File.directory?(File.join(path, ".git")) &&
  File.expand_path($0) == File.join(path, "bin", "bixby-agent") then

  ENV["BIXBY_HOME"] = path if not ENV["BIXBY_HOME"]
  require "bundler/setup"
end

require "bixby-common"
require "bixby-client"

require "bixby-agent/agent"
require "bixby-agent/version"

Bixby::Agent.setup_env()
