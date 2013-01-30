
require "bixby-client"

module Bixby
class Agent
  module Client

    def client
      @client ||= Bixby::Client.new(access_key, secret_key)
    end

    # Execute the given API request on the manager
    #
    # @param [JsonRequest] json_req
    # @return [JsonResponse]
    def exec_api(json_req)
      client.exec_api(json_req)
    end

    # Execute the given API download request
    #
    # @param [JsonRequest] json_req     Request to download a file
    # @param [String] download_path     Absolute filename to download requested file to
    # @return [JsonResponse]
    def exec_api_download(json_req, download_path)
      client.exec_api_download(json_req, download_path)
    end

  end # Client
end # Agent
end # Bixby
