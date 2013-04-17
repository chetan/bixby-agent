
require 'bixby_agent/server'
require 'bixby_agent/cli'

require 'daemons'
require 'thin'

module Bixby
class App

  include CLI

  def load_agent
    opts = {
      :uri       => @argv.empty? ? nil : @argv.shift,
      :root__dir => @config[:directory]
    }
    %w{port tenant password}.each{ |k| opts[k.to_sym] = @config[k.to_sym] }

    if @config[:debug] then
      ENV["BIXBY_DEBUG"] = "1"
    end

    begin
      agent = Agent.create(opts)
    rescue Exception => ex
      if ex.message == "Missing manager URI" then
        # if unable to load from config and no uri passed, bail!
        $stderr.puts "ERROR: manager uri is required the first time you call me!"
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
      if (ret = agent.register_agent(@config[:tags])).fail? then
        $stderr.puts "error: failed to register with manager!"
        $stderr.puts "reason:"
        $stderr.puts "  #{ret.message}"
        exit 1
      end
      agent.save_config()
    end
    agent
  end

  def run!

    agent = load_agent()

    Server.agent = agent
    Server.set :bind, "0.0.0.0"
    Server.set :port, agent.port
    Server.disable :protection
    # should probably just redirect these somewhere,
    # like "#{Agent.root}/logs/access|error.log"
    # Server.disable :logging
    # Server.disable :dump_errors

    ::Thin::Logging.silent = true

    if @config[:debug] then
      return Server.run!
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
      Server.run!
    end

  end

end # App
end # Bixby
