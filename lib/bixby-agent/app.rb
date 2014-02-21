
require 'bixby-agent/websocket/client'
require 'bixby-agent/agent_handler'
require 'bixby-agent/app/cli'

require 'daemons'

module Bixby
class App

  include CLI
  include Bixby::Log

  # Load Agent
  #
  # Load the agent from $BIXBY_HOME. If no existing configuration was found,
  # try to register with the server if we have the correct parameters.
  def load_agent
    opts = {
      :uri       => @argv.empty? ? nil : @argv.shift,
      :root_dir  => @config[:directory]
    }
    %w{tenant password}.each{ |k| opts[k.to_sym] = @config[k.to_sym] }

    begin
      agent = Agent.create(opts)
    rescue Exception => ex
      if ex.message =~ /manager URI/ then
        # if unable to load from config and no/bad uri passed, bail!
        $stderr.puts "ERROR: a valid manager URI is required on first run"
        $stderr.puts
        $stderr.puts @opt_parser.help()
        exit 1
      end
      raise ex
    end

    # TODO disable mac detection for now; it doesn't work in certain cases
    #      e.g., when you stop/start an instance on EC2 a new mac is issued
    #
    # if not agent.new? and agent.mac_changed? then
    #   # loaded from config and mac has changed
    #   agent = Agent.create(opts, false)
    # end

    if agent.new? then
      $stdout.puts "Going to register with manager: #{Bixby.manager_uri}"
      if (ret = agent.register_agent(@config[:tags])).fail? then
        $stderr.puts "error: failed to register with manager!"
        $stderr.puts "reason:"
        $stderr.puts "  #{ret.message}"
        exit 1
      end
      agent.save_config()
      ARGV.clear # make sure it's empty so daemon starts properly
      $stdout.puts "Registration successful; launching bixby-agent into background"
    end
    agent
  end

  # Run the agent app!
  #
  # This is the main method. Will boot and configure the agent, connect to the
  # server and start the daemon.
  def run!
    # load agent from config or cli opts
    agent = load_agent()

    fix_ownership()

    # debug mode, stay in front
    if @config[:debug] then
      Logging::Logger.root.add_appenders("stdout")
      return start_websocket_client()
    end

    # start daemon
    validate_argv()
    daemon_dir = Bixby.path("var")
    ensure_state_dir(daemon_dir)
    close_fds()

    daemon_opts = {
      :dir        => daemon_dir,
      :dir_mode   => :normal,
      :log_output => true,
      :stop_proc  => lambda { logger.info "Agent shutdown on service stop command" }
    }

    Daemons.run_proc("bixby-agent", daemon_opts) do
      Logging.logger.root.clear_appenders
      start_websocket_client()
    end
  end

  # Open the WebSocket channel with the Manager
  #
  # NOTE: this call will not return!
  def start_websocket_client
    # make sure log level is still set correctly here
    Bixby::Log.setup_logger(:level => Logging.appenders["file"].level)
    logger.info "Started Bixby Agent"
    @client = Bixby::WebSocket::Client.new(Bixby.agent.manager_ws_uri, AgentHandler)
    trap_signals()
    @client.start
  end

  def trap_signals
    %w{INT QUIT TERM}.each do |sig|
      Kernel.trap(sig) do
        @client.stop()
        puts # to get a blank line after the ^C in the term
        reason = sig + (sig == "INT" ? " (^C)" : "")
        logger.warn  "caught #{reason} signal; exiting"
      end
    end
  end

  # If running as root, fix ownership of var and etc dirs
  def fix_ownership
    return if Process.uid != 0
    begin
      uid = Etc.getpwnam("bixby").uid
      gid = Etc.getgrnam("bixby").gid
      # user/group exists, chown
      File.chown(uid, gid, Bixby.path("var"), Bixby.path("etc"))
    rescue ArgumentError
    end
  end

  # Validate ARGV
  #
  # If empty, default to "start", otherwise make sure we have a valid option
  # for daemons.
  #
  # @raise [SystemExit] on invalid arg
  def validate_argv
    if ARGV.empty? then
      ARGV << "start"
    else
      if not %w{start stop restart zap status}.include? ARGV.first then
        $stderr.puts "ERROR: invalid command '#{ARGV.first}'"
        $stderr.puts
        $stderr.puts @opt_parser.help()
        exit 1
      end
    end
  end

  # Ensure that the var dir exists and is writable
  #
  # @raise [SystemExit] on error
  def ensure_state_dir(daemon_dir)
    if not File.directory? daemon_dir then
      begin
        Dir.mkdir(daemon_dir)
      rescue Exception => ex
        $stderr.puts "Failed to create state dir: #{daemon_dir}; message:\n" + ex.message
        exit 1
      end
    end
    if not File.writable? daemon_dir then
      $stderr.puts "State dir is not writable: #{daemon_dir}"
      exit 1
    end
  end

  # Copied from daemons gem. We hit a bug where closing FDs failed,
  # probably related to prompting for a password. So close them
  # all cleanly before daemonizing.
  def close_fds
    # don't close stdin/out/err (0/1/2)
    3.upto(8192).each do |i|
      begin
        IO.for_fd(i).close
      rescue Exception
      end
    end
  end

end # App
end # Bixby
