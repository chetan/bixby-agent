
require 'bixby-agent/help/system_time'

require 'faye/websocket'
require 'eventmachine'
require 'timeout'

module Bixby
  module WebSocket

    # WebSocket Client
    class Client

      MAX_RECONNECT_TIME = 600

      include Bixby::Log

      attr_reader :ws, :api

      def initialize(url, handler)
        @url = url
        @handler = handler
        clear_errors()
        @exiting = false
        @thread_pool = Bixby::ThreadPool.new(:min_size => 1, :max_size => 4)
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

        logger.debug "connecting to #{@url}"
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

        # cleanup any previously opened connections
        if !@ws.nil? && ws.ready_state != Faye::WebSocket::API::CLOSED then
          begin
            @ws.close
          rescue Exception => ex
          end
        end

        # Ping is set to 55 sec to workaround issues with certain gateway devices which have a hard
        # 60 sec timeout, like the AWS ELB:
        # http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/ts-elb-healthcheck.html
        @ws = Faye::WebSocket::Client.new(@url, nil, :ping => 55)
        @api = Bixby::WebSocket::APIChannel.new(@ws, @handler, @thread_pool)

        ws.on :open do |e|
          begin
            authenticate(e)
          rescue Exception => ex
            logger.error ex
          end
        end

        ws.on :message do |e|
          begin
            api.message(e)
          rescue Exception => ex
            raise ex if ex.kind_of? SystemExit # possible when message is a connect() response
            logger.error ex
          end
        end

        ws.on(:close, &lambda { |e|
          begin
            was_connected = api.connected?
            api.close(e)
            return if @exiting or not EM.reactor_running?
            if was_connected then
              logger.info "lost connection to manager (code=#{e.code}; reason=\"#{e.reason}\")"
            else
              logger.debug "failed to connect"
            end
            reconnect()

          rescue SystemExit => ex
            logger.error(ex) if !@exiting
          rescue Exception => ex
            logger.error ex
          end
        })
      end

      # Send a connection request to authenticate with the manager
      def authenticate(e)
        logger.debug "connected to manager, authenticating"

        json_req   = JsonRequest.new("", "")
        signed_req = SignedJsonRequest.new(json_req, Bixby.agent.access_key, Bixby.agent.secret_key)
        auth_req   = Request.new(signed_req, SecureRandom.uuid, "connect")

        id = api.execute_async(auth_req) do |ret|
          if ret.success? then
            logger.info "Successfully connected to manager at #{@url}"
            api.open(e)
            clear_errors()

          else
            if ret.message =~ /900 seconds old/ then
              logger.error "error authenticating with manager:\n" + Help::SystemTime.message
            else
              logger.error "error authenticating with manager: #{ret.code} #{ret.message}"
            end
            logger.error "exiting since we failed to auth"
            @exiting = true
            exit 2 # bail out since we failed to connect, nothing to do
          end
        end

        # Start a thread to watch for auth timeout
        #
        # Because the CONNECT request is fully-async, we need to make sure a reply is received
        # within a certain time limit. If not, reconnect
        Thread.new do
          begin
            sec = 60
            Timeout.timeout(sec) do
              api.fetch_response(id) # blocks until request is completed
            end

          rescue Timeout::Error => ex
            @timeouts += 1
            logger.warn("Authentication timed out after #{sec} seconds; trying again")
            reconnect()

          rescue Exception => ex
            logger.error(ex)
          end
        end

      end

      def cleanup
        @api.close(nil) if @api
        @ws.close if @ws
      end

      def reconnect
        if @tries == 0 then
          @connect_start_time = Time.new
        end

        if backoff() then
          cleanup()
          connect()
        end
      end

      def clear_errors
        @tries = 0
        @timeouts = 0
        @connect_start_time = nil
      end

      # Delay reconnection by a slowly increasing interval
      def backoff

        if @exiting or not EM.reactor_running? then
          # shutting down, don't try to reconnect
          logger.info "not reconnecting since we are shutting down"
          return false
        end

        if @connect_start_time then
          diff = (Time.new-@connect_start_time).to_i
          if @timeouts > 0 && diff > MAX_RECONNECT_TIME then
            # Give up trying to reconnect
            #
            # This is to avoid issues where we get completely stuck trying to connect to the
            # manager. In at least one case, it seems EventMachine never sent our CONNECT request
            # and so we were never able to complete the auth process.
            #
            # In this situation, we expect the process to be automatically restarted via the
            # system supervisor (God, etc).
            logger.fatal "giving up since we have been trying for #{diff} seconds"
            logger.fatal "exiting"
            stop()
            exit 2
          end
        end

        @tries += 1
        if @tries == 1 then
          logger.info "retrying immediately"

        # :nocov:
        elsif @tries == 2 then
          logger.debug "retrying every 1 sec"
          sleep 1
        elsif @tries <= 30 then
          sleep 1
        elsif @tries == 31 then
          logger.debug "retrying every 5 sec"
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
