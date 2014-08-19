
require 'bixby-agent/help/system_time'

require 'faye/websocket'
require 'eventmachine'

module Bixby
  module WebSocket

    # WebSocket Client
    class Client

      include Bixby::Log

      attr_reader :ws, :api

      def initialize(url, handler)
        @url = url
        @handler = handler
        @tries = 0
        @exiting = false
      end

      # Start the Client thread
      #
      # NOTE: This call never returns!
      def start

        @exiting = false

        Kernel.trap("EXIT") do
          # :nocov:
          @exiting = true
          # :nocov:
        end

        log.debug "connecting to #{@url}"
        EM.run {
          connect()
        }
      end

      def stop
        @exiting = true
        EM.stop_event_loop if EM.reactor_running?
      end


      private

      # Connect to the WebSocket endpoint given by @url. Will attempt to keep
      # the connection open forever, reconnecting as needed.
      def connect

        # Ping is set to 55 sec to workaround issues with certain gateway devices which have a hard
        # 60 sec timeout, like the AWS ELB:
        # http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/ts-elb-healthcheck.html
        @ws = Faye::WebSocket::Client.new(@url, nil, :ping => 55)
        @api = Bixby::WebSocket::APIChannel.new(@ws, @handler)

        ws.on :open do |e|
          begin
            authenticate(e)
          rescue Exception => ex
            log.error ex
          end
        end

        ws.on :message do |e|
          begin
            api.message(e)
          rescue Exception => ex
            raise ex if ex.kind_of? SystemExit # possible when message is a connect() response
            log.error ex
          end
        end

        ws.on(:close, &lambda { |e|
          begin
            was_connected = api.connected?
            api.close(e)
            return if @exiting or not EM.reactor_running?
            if was_connected then
              log.info "lost connection to manager"
            else
              log.debug "failed to connect"
            end
            api.close(e)
            if backoff() then
              connect()
            end
          rescue Exception => ex
            log.error ex
          end
        })
      end

      # Send a connection request to authenticate with the manager
      def authenticate(e)
        log.debug "connected to manager, authenticating"

        json_req   = JsonRequest.new("", "")
        signed_req = SignedJsonRequest.new(json_req, Bixby.agent.access_key, Bixby.agent.secret_key)
        auth_req   = Request.new(signed_req, SecureRandom.uuid, "connect")

        api.execute_async(auth_req) do |ret|
          if ret.success? then
            log.info "Successfully connected to manager at #{@url}"
            api.open(e)
            @tries = 0

          else
            if ret.message =~ /900 seconds old/ then
              logger.error "error authenticating with manager:\n" + Help::SystemTime.message
            else
              log.error "error authenticating with manager: #{ret.code} #{ret.message}"
            end
            log.error "exiting since we failed to auth"
            @exiting = true
            exit 1 # bail out since we failed to connect, nothing to do
          end
        end
      end

      # Delay reconnection by a slowly increasing interval
      def backoff

        if @exiting or not EM.reactor_running? then
          # shutting down, don't try to reconnect
          log.debug "not retrying since we are shutting down"
          return false
        end

        @tries += 1
        if @tries == 1 then
          log.debug "retrying immediately"

        # :nocov:
        elsif @tries == 2 then
          log.debug "retrying every 1 sec"
          sleep 1
        elsif @tries <= 30 then
          sleep 1
        elsif @tries == 31 then
          log.debug "retrying every 5 sec"
          sleep 5
        else
          sleep 5
        end
        # :nocov:

        true
      end

    end

  end
end
