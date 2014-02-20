
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

        @ws = Faye::WebSocket::Client.new(@url, nil, :ping => 59)
        @api = Bixby::WebSocket::APIChannel.new(@ws, @handler)

        ws.on :open do |e|
          begin
            log.debug "connected to manager, authenticating"

            # send a connection request
            id = SecureRandom.uuid
            json_req = JsonRequest.new("", "")
            signed_req = SignedJsonRequest.new(json_req, Bixby.agent.access_key, Bixby.agent.secret_key)
            api.execute_async(Request.new(signed_req, id, "connect")) do |ret|
              if ret.success? then
                log.info "connected to manager at #{@url}"
                api.open(e)
                @tries = 0

              else
                log.error "error: #{ret.code} #{ret.message}"
                log.error "exiting since we failed to auth"
                @exiting = true
                exit 1 # bail out since we failed to connect, nothing to do
              end
            end

          rescue Exception => ex
            log.error ex
          end
        end

        ws.on :message do |e|
          begin
            api.message(e)
          rescue Exception => ex
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
