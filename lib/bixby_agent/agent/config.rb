
require 'yaml'
require 'fileutils'

module Bixby
class Agent

module Config

  module ClassMethods

    def config_dir
      File.join(self.agent_root, "etc")
    end

    def config_file
      File.join(config_dir, "bixby.yml")
    end

    # Setup logging
    #
    # @param [Symbol] level       Log level to use (default = :warn)
    def setup_logger(level=nil)
      # set level: ENV flag overrides; default to warn
      level = :debug if ENV["BIXBY_DEBUG"]
      level ||= :warn

      # TODO always use stdout for now
      Logging.appenders.stdout(
        :level  => level,
        :layout => Logging.layouts.pattern(:pattern => '[%d] %-5l: %m\n')
        )
      Logging::Logger.root.add_appenders(Logging.appenders.stdout)
      Logging::Logger.root.level = level
    end

    def load_config(root_dir)
      self.agent_root = (root_dir.nil? ? (ENV["BIXBY_HOME"] || Agent::DEFAULT_ROOT_DIR) : root_dir)
      ENV["BIXBY_HOME"] = self.agent_root # make sure its set TODO (do we need this?)

      return nil if not File.exists? config_file

      # load it!
      begin
        agent = YAML.load_file(config_file)
        if not agent.kind_of? Agent then
          bad_config("corrupted file contents")
        end
        agent.new = false
        setup_logger(agent.log_level)
        agent.log = Logging.logger[agent]
        return agent
      rescue Exception => ex
        if ex.kind_of? SystemExit then
          raise ex
        end
        bad_config(ex) if ex.message != "exit"
      end
    end

    def bad_config(ex = nil)
      # TODO should force a reinstall/handshake?
      $stderr.puts "error loading config from #{config_file}"
      $stderr.puts "(#{ex})" if ex
      $stderr.puts "exiting"
      exit 1
    end

  end # ClassMethods

  def self.included(clazz)
    clazz.extend(ClassMethods)
  end

  def new=(val)
    @new = val
  end

  def new?
    @new
  end

  def config_dir
    self.class.config_dir
  end

  def config_file
    self.class.config_file
  end

  def init_config_dir
    if not File.exists? config_dir then
      begin
        FileUtils.mkdir_p(config_dir)
      rescue Exception => ex
        raise IOError.new(ex.message)
      end
    end
  end

  def save_config
    init_config_dir()
    File.open(config_file, 'w') { |out| out.write(self.to_yaml) }
  end

  def to_yaml_properties
    %w{
      @port
      @manager_uri
      @uuid
      @mac_address
      @access_key
      @secret_key
      @log_level
    }
  end

end # Config

end # Agent
end # Bixby
