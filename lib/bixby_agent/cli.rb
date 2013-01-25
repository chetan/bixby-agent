
require 'mixlib/cli'
require 'optparse'

module Bixby
class App

module CLI

  include Mixlib::CLI

  def self.included(receiver)
    receiver.extend(Mixlib::CLI::ClassMethods)
    receiver.instance_variable_set(:@options, @options)
  end

  option :tenant,
      :short          => "-t TENANT",
      :long           => "--tenant TENANT",
      :description    => "Tenant name"

  option :password,
      :short          => "-P PASSWORD",
      :long           => "--password PASSWORD",
      :description    => "Agent registration password"

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
