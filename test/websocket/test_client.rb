
require 'helper'

module EventMachine
  class << self

    alias_method :_orig_run, :run
    alias_method :_orig_next_tick, :next_tick
    alias_method :_orig_stop, :stop
    alias_method :_orig_stop_event_loop, :stop_event_loop

    def run_immediately(&block)
      @reactor_running = true
      block.call() if block
    end

    def tick_immediately(&block)
      block.call() if block
    end

    def noop
    end

    def stub!
      define_singleton_method :run, method(:run_immediately)
      define_singleton_method :next_tick, method(:tick_immediately)
      define_singleton_method :stop, method(:noop)
      define_singleton_method :stop_event_loop, method(:noop)
    end

    def disable_stub!
      define_singleton_method :run, method(:_orig_run)
      define_singleton_method :next_tick, method(:_orig_next_tick)
      define_singleton_method :stop, method(:_orig_stop)
      define_singleton_method :stop_event_loop, method(:_orig_stop_event_loop)
    end

  end
end

module Bixby
module Test

  class TestHandler < Bixby::RpcHandler
  end

module WebSocket
class TestClient < TestCase

  class FakeClient
    attr_reader :types
    def initialize
      @types = {}
    end
    def on(type, &block)
      @types[type] = block
    end
    def trigger(type, event)
      @types[type].call(event)
    end
  end

  def setup
    super
    EM.stub!
    setup_existing_agent()
    Logging.logger[Bixby::WebSocket::Client].level = 5
  end

  def teardown
    EM.disable_stub!
  end

  def test_connect_and_reconnect

    @fake_ws = FakeClient.new
    # created twice due to reconnect
    Faye::WebSocket::Client.expects(:new).with("http://localhost", nil, :ping => 60).returns(@fake_ws).times(2)
    @client = Bixby::WebSocket::Client.new("http://localhost", TestHandler)
    @client.start

    assert @fake_ws.types[:open]
    assert @fake_ws.types[:message]
    assert @fake_ws.types[:close]

    # connect
    @fake_ws.expects(:send).with{ |r| c = Bixby::WebSocket::Message.from_wire(r); c.type == "connect" }.times(2)
    @fake_ws.trigger(:open, nil)
    assert @client.api.connected?

    # reconnect
    @fake_ws.trigger(:close, nil)
    refute @client.api.connected?

    # stop w/o backoff/reconnect
    @fake_ws.trigger(:open, nil)
    assert @client.api.connected?

    EM.expects(:stop_event_loop).once()
    @client.stop()
    @fake_ws.trigger(:close, nil)
    refute @client.api.connected?
  end

  def test_message
    @fake_ws = FakeClient.new
    Faye::WebSocket::Client.expects(:new).with("http://localhost", nil, :ping => 60).returns(@fake_ws)
    @client = Bixby::WebSocket::Client.new("http://localhost", TestHandler)
    @client.start

    @client.api.expects(:message).once.with("foobar")
    @fake_ws.trigger(:message, "foobar")
  end

end
end
end
end
