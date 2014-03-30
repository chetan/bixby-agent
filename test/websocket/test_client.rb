
require 'helper'
require 'stub_eventmachine'

module Bixby

  module WebSocket
    class APIChannel < Bixby::APIChannel
      attr_reader :responses # expose for testing
    end
  end

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
    Faye::WebSocket::Client.expects(:new).with("http://localhost", nil, :ping => 55).returns(@fake_ws).times(2)
    @client = Bixby::WebSocket::Client.new("http://localhost", TestHandler)
    @client.start

    assert @fake_ws.types[:open]
    assert @fake_ws.types[:message]
    assert @fake_ws.types[:close]

    # connect
    @fake_ws.expects(:send).with{ |r| c = Bixby::WebSocket::Message.from_wire(r); c.type == "connect" }.times(2)
    @fake_ws.trigger(:open, nil)
    @client.api.responses.values.first.response = JsonResponse.new("success")
    assert @client.api.connected?

    # reconnect
    @fake_ws.trigger(:close, nil)
    refute @client.api.connected?

    # stop w/o backoff/reconnect
    @fake_ws.trigger(:open, nil)
    @client.api.responses.values.first.response = JsonResponse.new("success")
    assert @client.api.connected?

    EM.expects(:stop_event_loop).once()
    @client.stop()
    @fake_ws.trigger(:close, nil)
    refute @client.api.connected?
  end

  def test_message
    @fake_ws = FakeClient.new
    Faye::WebSocket::Client.expects(:new).with("http://localhost", nil, :ping => 55).returns(@fake_ws)
    @client = Bixby::WebSocket::Client.new("http://localhost", TestHandler)
    @client.start

    @client.api.expects(:message).once.with("foobar")
    @fake_ws.trigger(:message, "foobar")
  end

end
end
end
end
