
require 'sinatra/base'

module Bixby
class Server < Sinatra::Base

  SHELL_EXEC = "shell_exec"

  DEFAULT_PORT = 18000

  class << self
    attr_accessor :agent
  end

  def initialize
    super
    @log = Logging.logger[self]
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

    return handle_exec(req)
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

  # Handle the exec request and return the response
  #
  # @return [JsonResponse]
  def handle_exec(req)
    begin
      cmd_res = agent.shell_exec(req.params)
      @log.debug { cmd_res.to_s + "\n---\n\n\n" }
      return cmd_res.to_json_response

    rescue Exception => ex
      if ex.kind_of? BundleNotFound then
        return JsonResponse.bundle_not_found(ex.message)
      elsif ex.kind_of? CommandNotFound then
        return JsonResponse.command_not_found(ex.message)
      end
      @log.error(ex)
      return JsonResponse.new("fail", ex.message, nil, 500)
    end
  end

end # Server
end # Bixby
