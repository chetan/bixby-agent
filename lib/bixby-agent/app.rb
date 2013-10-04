
require 'bixby-agent/websocket/client'
require 'bixby-agent/agent_handler'
require 'bixby-agent/cli'

require 'daemons'

module Bixby
class App

  include CLI

  # Load Agent
  #
  # Load the agent from $BIXBY_HOME. If no existing configuration was found,
  # try to register with the server if we have the correct parameters.
  def load_agent
    opts = {
      :uri       => @argv.empty? ? nil : @argv.shift,
      :root_dir  => @config[:directory]
    }
    %w{port tenant password}.each{ |k| opts[k.to_sym] = @config[k.to_sym] }

    if @config[:debug] then
      ENV["BIXBY_DEBUG"] = "1"
    end

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
      $stdout.puts "Registration successful; launching bixby-agent into background on port #{agent.port}"
    end
    agent
  end

  # Run the agent app!
  #
  # This is the main method. Will boot and configure the agent, connect to the
  # server and start the daemon.
  def run!

    agent = load_agent()

    if @config[:debug] then
      Logging::Logger.root.add_appenders("stdout")
      Kernel.trap("INT") do
        @client.stop()
        puts
        puts "exiting on ^C"
      end
      return start_websocket_client()
    end

    daemon_dir = File.join(Bixby.root, "var")
    if not File.directory? daemon_dir then
      begin
        Dir.mkdir(daemon_dir)
      rescue Exception => ex
        $stderr.puts "Failed to create state dir: #{daemon_dir}; message:\n" + ex.message
        exit 1
      end
    end

    # Copied from daemons. We hit a bug where closing FDs failed,
    # probably related to prompting for a password. So close them
    # all cleanly before daemonizing.
    ios = Array.new(8192) {|i| IO.for_fd(i) rescue nil}.compact
    ios.each do |io|
      next if io.fileno < 3
      begin
        io.close
      rescue Exception
      end
    end

    daemon_opts = {
      :dir        => daemon_dir,
      :dir_mode   => :normal,
      :log_output => true
    }

    if ARGV.empty? then
      ARGV << "start"
    end

    Daemons.run_proc("bixby-agent", daemon_opts) do
      start_websocket_client()
    end

  end

  # Open the WebSocket channel with the Manager
  #
  # NOTE: this call will not return!
  def start_websocket_client
    # make sure log level is still set correctly here
    Bixby::Log.setup_logger(:level => Logging.appenders["file"].level)
    @client = Bixby::WebSocket::Client.new(Bixby.agent.manager_ws_uri, AgentHandler)
    @client.start
  end

end # App
end # Bixby
