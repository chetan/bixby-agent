
require 'mixlib/cli'
require 'highline/import'

module Bixby
class App

module CLI

  include Mixlib::CLI

  def self.included(receiver)
    receiver.extend(Mixlib::CLI::ClassMethods)
    receiver.instance_variable_set(:@options, @options)
    receiver.instance_variable_set(:@banner, @banner)
  end

  banner <<-EOF
Usage: #{$0}

Run bixby-agent as a background daemon.

Register with manager:

  #{$0} [-p PORT] -t TENANT -P PASSWORD <manager url>

Options:

EOF

  option :tenant,
      :short          => "-t TENANT",
      :long           => "--tenant TENANT",
      :description    => "Tenant name"

  option :password,
      :short          => "-P [PASSWORD]",
      :long           => "--password [PASSWORD]",
      :description    => "Agent registration password (prompt if not supplied)",
      :proc           => Proc.new { |c|
                           if c then
                             c
                           else
                             HighLine.new.ask("Enter password: ") { |q| q.echo = "*" }
                           end
                         }

  option :directory,
      :short          => "-d DIRECTORY",
      :long           => "--directory DIRECTORY",
      :default        => "/opt/bixby",
      :description    => "Root directory for Bixby (default: /opt/bixby)"

  option :port,
      :short          => "-p PORT",
      :long           => "--port PORT",
      :default        => Bixby::Server::DEFAULT_PORT,
      :description    => "Port agent will listen on (default: #{Bixby::Server::DEFAULT_PORT})"

  option :debug,
      :long           => "--debug",
      :description    => "Enable debugging messages",
      :boolean        => true

  option :help,
      :short          => "-h",
      :long           => "--help",
      :description    => "Print this help",
      :boolean        => true,
      :show_options   => true,
      :exit           => 0

  option :version,
      :short          => "-v",
      :long           => "--version",
      :description    => "Show version",
      :proc           => Proc.new { puts "Bixby v" + Bixby::Agent::VERSION },
      :exit           => 0


  def initialize
    super
    @argv = parse_options()
  end

end # CLI

end # App
end # Bixby
