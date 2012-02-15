
class TestRemoteExec < ActiveSupport::TestCase

  def setup
    WebMock.reset!
  end

  def test_create_spec
      c = CommandSpec.new(:repo => "support", :bundle => "foobar")
      assert_equal c, RemoteExec.create_spec(c)

      repo = Repo.new(:name => "vendor")
      cmd = Command.new(:bundle => "foobar", :command => "baz", :repo => repo)
      cs = RemoteExec.create_spec(cmd)

      assert_not_equal cs, cmd
      assert_equal "baz", cs.command
      assert_equal "foobar", cs.bundle

  end

  def test_exec
    repo  = Repo.new(:name => "vendor")
    agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
    cmd   = Command.new(:bundle => "foobar", :command => "baz", :repo => repo)

    stub = stub_request(:post, "http://2.2.2.2:18000/").
              with(:body => '{"operation":"exec","params":{"repo":"vendor","bundle":"foobar","command":"baz"}}').
              to_return(:status => 200, :body => JsonResponse.new("success").to_json)

    ret = RemoteExec.exec(agent, cmd)

    assert_requested(stub)
    assert_equal "success", ret.status
  end

  def test_exec_with_provision

    BundleRepository.path = "#{Rails.root}/test"
    repo  = Repo.new(:name => "support")
    agent = Agent.new(:ip => "2.2.2.2", :port => 18000)
    cmd   = Command.new(:bundle => "test_bundle", :command => "echo", :repo => repo)

    url = "http://2.2.2.2:18000/"
    res = []
    res << JsonResponse.bundle_not_found(cmd).to_json
    res << JsonResponse.new("success", "", {:stdout => "frobnicator echoed"}).to_json
    stub = stub_request(:post, url).
              with(:body => '{"operation":"exec","params":{"repo":"support","bundle":"test_bundle","command":"echo"}}').
              to_return { { :status => 200, :body => res.shift } }

    stub2 = stub_request(:post, url).with { |req|
      req.body =~ %r{system/provisioning} and req.body =~ /get_bundle.rb/
    }.to_return(:status => 200, :body => JsonResponse.new("success", "", {}).to_json).times(3)

    ret = RemoteExec.exec(agent, cmd)

    assert_requested(stub, :times => 2)
    assert_requested(stub2, :times => 1)
    assert_equal "success", ret.status
    assert_equal "frobnicator echoed", ret.data["stdout"]
  end

end