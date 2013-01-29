
require "api-auth"

module Bixby
class Agent
  module API

    # Execute the given API request on the manager
    #
    # @param [String] operation  Name of operation
    # @param [Array] params  Array of parameters; must ve valid JSON types
    def api_call(op, params)
      exec_api(JsonRequest.new(op, params))
    end

    # Execute the given API download request
    #
    # @param [JsonRequest] json_req     Request to download a file
    # @param [String] download_path     Absolute filename to download requested file to
    # @return [JsonResponse]
    def exec_download(download_path, op, params)
      exec_api_download(JsonRequest.new(op, params), download_path)
    end

    # Execute the given API request on the manager
    #
    # @param [JsonRequest] json_req
    # @return [JsonResponse]
    def exec_api(json_req)
      begin
        req = sign_request(json_req)
        res = HTTPI.post(req).body
        return JsonResponse.from_json(res)
      rescue Curl::Err::CurlError => ex
        return JsonResponse.new("fail", ex.message, ex.backtrace)
      end
    end

    # Execute the given API download request
    #
    # @param [JsonRequest] json_req     Request to download a file
    # @param [String] download_path     Absolute filename to download requested file to
    # @return [JsonResponse]
    def exec_api_download(json_req, download_path)
      begin
        req = sign_request(json_req)
        File.open(download_path, "w") do |io|
          req.on_body { |d| io << d; d.length }
          HTTPI.post(req)
        end
        return JsonResponse.new("success")
      rescue Curl::Err::CurlError => ex
        return JsonResponse.new("fail", ex.message, ex.backtrace)
      end
    end


    private

    # Create a signed request
    #
    # @param [JsonRequest] json_req
    #
    # @return [HTTPI::Request]
    def sign_request(json_req)
      post = json_req.to_json
      req = HTTPI::Request.new(:url => api_uri, :body => post)
      req.headers["Content-Type"] = "application/json"

      if crypto_enabled? and have_server_key? then
        ApiAuth.sign!(req, access_key, secret_key)
      end

      return req
    end

    def api_uri
      URI.join(Bixby.manager_uri, "/api").to_s
    end

  end # API
end # Agent
end # Bixby
