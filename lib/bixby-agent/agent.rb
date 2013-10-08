
require "uri"
require "rbconfig"

require "bixby-agent/config_exception"
require "bixby-agent/agent/handshake"
require "bixby-agent/agent/shell_exec"
require "bixby-agent/agent/config"

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

  attr_accessor :manager_uri, :uuid, :mac_address, :tenant, :password,
                :access_key, :secret_key, :client

  def self.create(opts={}, use_config = true)

    agent = load_config(opts[:root_dir]) if use_config

    if agent.nil? then
      # create a new one if unable to load

      if File.exists? config_file then
        $stderr.puts "Unable to load agent from BIXBY_HOME=#{ENV['BIXBY_HOME']}; going to initialize"
      end

      uri = opts[:uri]
      begin
        if uri.nil? or URI.parse(uri).nil? or URI.join(uri, "/api").nil? then
          raise ConfigException, "Missing manager URI", caller
        end
      rescue URI::Error => ex
        raise ConfigException, "Bad manager URI: '#{uri}'"
      end

      agent = new(opts)
    end

    # pass config to some modules
    Bixby.agent = agent
    Bixby.manager_uri = agent.manager_uri
    Bixby.client = Bixby::Client.new(agent.access_key, agent.secret_key)

    return agent
  end

  def initialize(opts)
    #uri, tenant = nil, password = nil, root_dir = nil
    Bixby::Log.setup_logger()
    @new = true

    @manager_uri = opts[:uri]
    @tenant = opts[:tenant]
    @password = opts[:password]

    @uuid = create_uuid()
    @mac_address = get_mac_address()
    create_keypair()
  end
  private_class_method :new

  # Setup the environment for shelling out. Makes sure the correct Ruby
  # version is on the path and that bixby-agent will be loaded by default
  def self.setup_env
    # make sure the correct ruby version is on the path
    c = begin; ::RbConfig::CONFIG; rescue NameError; ::Config::CONFIG; end
    ruby_dir = File.expand_path(c['bindir'])

    shell = Mixlib::ShellOut.new("which ruby")
    shell.run_command
    if not $?.success? or File.dirname(shell.stdout.strip) != ruby_dir then
      ENV["PATH"] = ruby_dir + File::PATH_SEPARATOR + ENV["PATH"]
    end

    # create RUBYLIB paths
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
    ENV["RUBYOPT"] = '-rbixby-client/script'
  end

  # Get the WebSocket API URI
  #
  # @return [String] uri
  def manager_ws_uri
    # convert manager uri to websocket
    uri = URI.parse(manager_uri)
    uri.scheme = "ws"
    uri.path = "/wsapi"
    return uri.to_s
  end

end # Agent
end # Bixby
