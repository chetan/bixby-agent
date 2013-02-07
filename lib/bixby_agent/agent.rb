
require "uri"
require "rbconfig"

require "bixby_agent/config_exception"
require "bixby_agent/agent/handshake"
require "bixby_agent/agent/shell_exec"
require "bixby_agent/agent/config"

module Bixby

class << self
  attr_accessor :agent
end

class Agent

  DEFAULT_ROOT_DIR = "/opt/bixby"

  include Bixby::Log
  include Config
  include Handshake
  include ShellExec

  attr_accessor :port, :manager_uri, :uuid, :mac_address, :tenant, :password,
                :log_level, :access_key, :secret_key, :client

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
    Bixby.agent = agent
    Bixby.manager_uri = agent.manager_uri
    Bixby.client = Bixby::Client.new(agent.access_key, agent.secret_key)

    return agent
  end

  def initialize(uri, tenant = nil, password = nil, root_dir = nil, port = nil)
    @new = true

    @log = Logging.logger[self]

    @port = port
    @manager_uri = uri
    @tenant = tenant
    @password = password

    @uuid = create_uuid()
    @mac_address = get_mac_address()
    create_keypair()
  end
  private_class_method :new

  # Setup the environment for shelling out. Makes sure the correct Ruby
  # version is on the path and that bixby-agent will be loaded by default
  def self.setup_env
    paths = []
    if ENV.include? "RUBYLIB" and not ENV["RUBYLIB"].empty? then
      paths = ENV["RUBYLIB"].split(/:/)
    end
    $:.each { |p|
      if p =~ %r(/gems/) and not paths.include? p then
        paths << p
      end
    }
    self_lib = File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib'))
    paths << self_lib if not paths.include? self_lib
    ENV["RUBYLIB"] = paths.join(":")
    ENV["RUBYOPT"] = '-rbixby-agent'

    # make sure the correct ruby version is on the path
    c = begin; ::RbConfig::CONFIG; rescue NameError; ::Config::CONFIG; end
    ruby_dir = File.expand_path(c['bindir'])
    stdout = `which ruby` # don't use systemu here to avoid recursive issues
    if not $?.success? or File.dirname(stdout.strip) != ruby_dir then
      ENV["PATH"] = ruby_dir + File::PATH_SEPARATOR + ENV["PATH"]
    end

  end

end # Agent
end # Bixby
