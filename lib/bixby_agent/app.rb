
require 'bixby_agent/server'
require 'bixby_agent/cli'

require 'daemons'
require 'thin'

module Bixby
class App

  include CLI

  def load_agent
    uri = @argv.empty? ? nil : @argv.shift
    root_dir = @config[:directory]
    port     = @config[:port]
    tenant   = @config[:tenant]
    password = @config[:password]

    begin
      agent = Agent.create(uri, tenant, password, root_dir, port)
    rescue Exception => ex
      if ex.message == "Missing manager URI" then
        # if unable to load from config and no uri passed, bail!
        puts "ERROR: manager uri is required the first time you call me!"
        puts
        puts @opt_parser.help()
        exit
      end
      raise ex
    end

    if not agent.new? and agent.mac_changed? then
      # loaded from config and mac has changed
      agent.deregister_agent()
      agent = Agent.create(uri, tenant, password, root_dir, false)
    end

    if agent.new? then
      if (ret = agent.register_agent()).fail? then
        puts "error: failed to register with manager!"
        puts "reason:"
        puts "  #{ret.message}"
        exit(1)
      end
      agent.save_config()
    end
    agent
  end

  def setup_logger
    level = @config[:debug] ? :debug : :warn
    Logging.appenders.stdout(
      :level  => level,
      :layout => Logging.layouts.pattern(:pattern => '[%d] %-5l: %m\n')
      )
    Logging::Logger.root.add_appenders(Logging.appenders.stdout)
    Logging::Logger.root.level = level
  end

  def run!

    setup_logger()

    agent = load_agent()

    Server.agent = agent
    Server.set :port, agent.port
    Server.disable :protection
    # should probably just redirect these somewhere,
    # like "#{Agent.root}/logs/access|error.log"
    # Server.disable :logging
    # Server.disable :dump_errors

    ::Thin::Logging.silent = true

    if not @config[:debug] then
      daemon_dir = File.join(agent.root, "var")
      if not File.directory? daemon_dir then
        begin
          Dir.mkdir(daemon_dir)
        rescue Exception => ex
          puts "Failed to create state dir: #{daemon_dir}; message:\n" + ex.message
          exit 1
        end
      end
      Daemons.daemonize({
        :app_name   => "bixby_agent",
        :dir        => daemon_dir,
        :dir_mode   => :normal,
        :log_output => true
        })
    end

    Server.run!
  end

end # App
end # Bixby
