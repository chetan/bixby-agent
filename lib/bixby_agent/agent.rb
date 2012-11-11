
require "uri"
require "logging"

require "bixby_agent/config_exception"
require "bixby_agent/agent/handshake"
require "bixby_agent/agent/exec"
require "bixby_agent/agent/api"
require "bixby_agent/agent/config"

module Bixby
class Agent

  DEFAULT_ROOT_DIR = "/opt/bixby"

  include HttpClient
  include Config
  include Handshake
  include Exec
  include API

  class << self
    attr_accessor :agent_root
  end

  def agent_root
    self.class.agent_root
  end

  def agent_root=(path)
    self.class.agent_root = path
  end

  attr_accessor :port, :manager_uri, :uuid, :mac_address, :tenant, :password, :log

  def self.create(uri = nil, tenant = nil, password = nil, root_dir = nil, port = nil, use_config = true)

    agent = load_config(root_dir) if use_config

    if agent.nil? and (uri.nil? or URI.parse(uri).nil?) then
      raise ConfigException, "Missing manager URI", caller
    end

    if agent.nil? then
      # create a new one if unable to load
      uri = uri.gsub(%r{/$}, '') # remove trailing slash
      agent = new(uri, tenant, password, root_dir, port)
    end

    # pass config to some modules
    BundleRepository.path = File.join(agent.agent_root, "/repo")
    BaseModule.agent = agent
    BaseModule.manager_uri = agent.manager_uri
    agent.setup_env()

    return agent
  end

  def initialize(uri, tenant = nil, password = nil, root_dir = nil, port = nil)
    @new = true

    @log = Logging.logger[self]

    @port = port
    @manager_uri = uri
    @tenant = tenant
    @password = password
    @agent_root = root_dir.nil? ? DEFAULT_ROOT_DIR : root_dir

    @uuid = create_uuid()
    @mac_address = get_mac_address()
    create_keypair()
  end
  private_class_method :new

  def setup_env
    # setup the env for child processes
    ENV["BIXBY_HOME"] = self.agent_root

    paths = []
    paths << ENV["RUBYLIB"] if ENV.include? "RUBYLIB" and not ENV["RUBYLIB"].empty?
    $:.each{ |p| paths << p if p =~ %r(/gems/) }
    paths << File.join(self.agent_root, 'lib')
    ENV["RUBYLIB"] = paths.join(":")
    ENV["RUBYOPT"] = '-rbixby_agent'
  end

end # Agent
end # Bixby
