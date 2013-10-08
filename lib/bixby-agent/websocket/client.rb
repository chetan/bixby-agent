
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

        @ws = Faye::WebSocket::Client.new(@url, nil, :ping => 60)
        @api = Bixby::WebSocket::APIChannel.new(@ws, @handler)

        ws.on :open do |e|
          begin
            log.info "connected to manager at #{@url}"
            api.open(e)
            @tries = 0

            # send a connection request
            id = SecureRandom.uuid
            json_req = JsonRequest.new("", "")
            signed_req = SignedJsonRequest.new(json_req, Bixby.agent.access_key, Bixby.agent.secret_key)
            connect_req = Request.new(signed_req, id, "connect")
            EM.next_tick {
              ws.send(connect_req.to_wire)
            }

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

        ws.on :close do |e|
          begin
            if api.connected? then
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
        end
      end

      # Delay reconnection by a slowly increasing interval
      def backoff

        if @exiting or not EM.reactor_running? then
          # shutting down, don't try to reconnect
          puts "not retrying"
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
