
AGENT_ROOT = File.expand_path(File.join(File.dirname(__FILE__)))
$:.unshift(AGENT_ROOT) if not $:.include? AGENT_ROOT

require "bixby_common"

require 'bixby_agent/model/bundle_command'
require "bixby_agent/agent"

Bixby::Agent.setup_env()
