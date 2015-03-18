
require 'mixlib/cli'

module Bixby
class App

module CLI

  include Mixlib::CLI

  def self.included(receiver)
    receiver.extend(Mixlib::CLI::ClassMethods)
    receiver.instance_variable_set(:@options, @options)
    receiver.instance_variable_set(:@banner, @banner)
    receiver.instance_variable_set(:@opt_parser, @opt_parser)
  end

  banner <<-EOF
Usage: #{$0} <command>

Run bixby-agent as a background daemon.

Where <command> is one of:
  start         start the agent
  stop          stop the agent
  restart       stop and start the agent
  zap           reset the PID file
  status        show status (PID) of the agent

To register with the manager:

  #{$0} --register [URL] --token TOKEN [--tags TAG1,TAG2]

Options:

EOF

  # :nocov:

  option :register,
      :on             => :head,
      :long           => "--register [URL]",
      :description    => "Register with the management server (optional URL, default: https://bixby.io)",
      :proc           => Proc.new { |url| url || "https://bixby.io" } # default URL

  option :token,
      :on             => :head,
      :short          => "-t TOKEN",
      :long           => "--token TOKEN",
      :description    => "Client registration token"

  option :tags,
      :on             => :head,
      :long           => "--tags TAGS",
      :description    => "Comma separated tags to assign to this host (optional)"

  option :directory,
      :short          => "-d DIRECTORY",
      :long           => "--directory DIRECTORY",
      :description    => "Root directory for Bixby (optional, default: /opt/bixby)"

  option :debug,
      :on             => :tail,
      :long           => "--debug",
      :description    => "Enable debug mode (don't daemonize, extra logging)",
      :boolean        => true,
      :proc           => Proc.new { ENV["BIXBY_LOG"] = "debug" }

  option :help,
      :on             => :tail,
      :short          => "-h",
      :long           => "--help",
      :description    => "Print this help",
      :boolean        => true,
      :show_options   => true,
      :exit           => 0

  option :version,
      :on             => :tail,
      :short          => "-v",
      :long           => "--version",
      :description    => "Show version",
      :proc           => Proc.new { puts "Bixby v" + Bixby::Agent::VERSION },
      :exit           => 0

  # :nocov:

  def initialize
    super
    @argv = parse_options()
    ARGV.clear << @argv
    ARGV.flatten!
  end

end # CLI

end # App
end # Bixby
