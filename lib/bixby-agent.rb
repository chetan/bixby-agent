
# Set BIXBY_HOME when in dev environment
path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
if !ENV["BIXBY_HOME"] && File.directory?(File.join(path, ".git")) &&
    File.basename($0) == "bixby-agent" then

  ENV["BIXBY_HOME"] = path
end

require "bixby-common"
require "bixby-client"

require "bixby-agent/agent"
require "bixby-agent/version"

Bixby::Agent.setup_env()
