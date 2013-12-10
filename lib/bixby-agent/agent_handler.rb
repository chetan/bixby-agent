
module Bixby

  class AgentHandler < Bixby::RpcHandler

    include Bixby::Log
    # include Bixby::CryptoUti

    def initialize(request)
      @request = request
    end

    def handle(json_req)

      begin
        cmd_res = Bixby.agent.shell_exec(json_req.params)
        log.debug { cmd_res.to_s + "\n---\n\n\n" }
        return cmd_res.to_json_response

      rescue Exception => ex
        if ex.kind_of? BundleNotFound then
          log.debug(ex.message)
          return JsonResponse.bundle_not_found(ex.message)

        elsif ex.kind_of? CommandNotFound then
          log.debug(ex.message)
          return JsonResponse.command_not_found(ex.message)
        end

        log.error(ex)
        return JsonResponse.new("fail", ex.message, nil, 500)
      end

    end

  end

end
