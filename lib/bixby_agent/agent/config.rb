
require 'yaml'
require 'fileutils'

module Bixby
class Agent

module Config

  KEYS = %w{ port manager_uri uuid mac_address access_key secret_key log_level }

  module ClassMethods

    def config_dir
      Bixby.path("etc")
    end

    def config_file
      File.join(config_dir, "bixby.yml")
    end

    def load_config(root_dir)
      # make sure BIXBY_HOME is set correctly
      ENV["BIXBY_HOME"] = root_dir || ENV["BIXBY_HOME"] || Agent::DEFAULT_ROOT_DIR

      return nil if not File.exists? config_file

      # load it!
      begin
        config = YAML.load_file(config_file)
        if not config.kind_of? Hash or config.empty? then
          bad_config("corrupted file contents")
        end
        Bixby::Log.setup_logger(config["log_level"])

        agent = Agent.allocate
        KEYS.each do |k|
          m = "#{k}=".to_sym
          agent.send(m, config[k]) if agent.respond_to? m
        end
        agent.new = false

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
    return if File.exists? config_dir
    begin
      FileUtils.mkdir_p(config_dir)
    rescue Exception => ex
      raise IOError.new(ex.message)
    end
  end

  def save_config
    init_config_dir()
    config = {}
    KEYS.each do |k|
      m = k.to_sym
      config[k] = self.send(m) if self.respond_to? m
    end
    config["log_level"] = Logging::Logger.root.level
    File.open(config_file, 'w') { |out| out.write YAML.dump(config) }
  end

end # Config

end # Agent
end # Bixby
