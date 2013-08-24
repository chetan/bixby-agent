
require 'sinatra/base'

module Bixby
class Server < Sinatra::Base

  SHELL_EXEC = "shell_exec"

  DEFAULT_PORT = 18000

  class << self
    attr_accessor :agent, :debug
  end

  # Configure various server settings
  def self.configure(agent)
    Server.agent = agent
    Server.debug = @config[:debug]
    Server.set :bind, "0.0.0.0"
    Server.set :port, agent.port
    Server.disable :protection
    # should probably just redirect these somewhere,
    # like "#{Agent.root}/logs/access|error.log"
    # Server.disable :logging
    # Server.disable :dump_errors
  end

  def initialize
    super
    Bixby::Log.setup_logger(:level => Logging.appenders["file"].level)
    @log = Logging.logger[self]
    @log.add_appenders("file") if @log.appenders.empty?
    @log.additive = false

    # filter sinatra/rack/thin from stacktraces
    layout = Bixby::Log::FilteringLayout.new(:pattern => Logging.appenders["file"].layout.pattern)
    layout.set_filter do |ex|
      server = false
      ex.backtrace.reject{ |s|
        if server or s.include? "/lib/sinatra/" then
          server = true
          true
        else
          false
        end
      }
    end
    Logging.appenders["file"].layout = layout

    if self.class.debug then
      Logging.appenders.stdout( 'stdout',
        :auto_flushing => true,
        :layout => Logging.appenders["file"].layout
      )
      @log.add_appenders("stdout")
    end

  end

  def agent
    self.class.agent
  end

  get '/*' do
    @log.debug { "Disposing of GET request: #{request.path}" }
    status 405
    return "GET requests are not allowed\n"
  end

  post '/*' do
    res = handle_request().to_json
    return encrypt(res)
  end

  # Encrypt the response
  #
  # @param [String] json      json response
  #
  # @return [String] base64 encrypted response when crypto is enabled,
  #                  otherwise, plain json
  def encrypt(json)
    agent.crypto_enabled? ? agent.encrypt_for_server(json) : json
  end

  def handle_request
    req = extract_valid_request()
    if req.kind_of? JsonResponse then
      @log.debug { "request extraction failed" }
      return req
    end

    return AgentHandler.new(request).handle(req)
  end

  def extract_valid_request
    body = request.body.read.strip
    if body.nil? or body.empty? then
      return JsonResponse.invalid_request
    end

    if agent.crypto_enabled? then
      body = agent.decrypt_from_server(body)
    end

    begin
      req = JsonRequest.from_json(body)
    rescue Exception
      return JsonResponse.invalid_request
    end

    if SHELL_EXEC != req.operation then
      return JsonResponse.invalid_request("unsupported operation: #{req.operation}")
    end

    return req
  end

end # Server
end # Bixby
