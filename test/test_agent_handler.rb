
require 'helper'

module Bixby
module Test
class TestAgentHandler < TestCase

  def setup
    super
    ENV["BIXBY_HOME"] = nil

    setup_existing_agent()
    @agent = create_new_agent()
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir

    # more setup
    setup_test_bundle("support", "test_bundle", "echo",
      "c1af0e59a74367e83492a7501f6bdd7ed33de005c3f727a302c5ddfafa8c6f70")
    setup_root()
  end

  def teardown
    ENV["BIXBY_HOME"] = nil
  end

  def test_handle
    @c.args = "foobar"
    req = JsonRequest.new("shell_exec", @c.to_hash)

    res = AgentHandler.new(nil).handle(req) # this is the actual test call
    assert res
    assert_kind_of JsonResponse, res
    assert res.success? # shell exec succeeded

    res = CommandResponse.from_json_response(res)
    assert_kind_of CommandResponse, res
    assert res.success? # actual command succeeded
    assert_equal 0, res.status
    assert_equal "foobar\n", res.stdout
    assert_equal "", res.stderr
  end

  def test_handle_bundle_not_found
    @c.bundle = "foo"
    req = JsonRequest.new("shell_exec", @c.to_hash)

    res = AgentHandler.new(nil).handle(req)
    puts res.to_s
    refute res.success?
    assert_equal 404, res.code
    assert res.message =~ /bundle not found/
    assert_equal nil, res.data
  end

  def test_handle_command_not_found
    @c.command = "foo"
    req = JsonRequest.new("shell_exec", @c.to_hash)

    res = AgentHandler.new(nil).handle(req)
    puts res.to_s
    refute res.success?
    assert_equal 404, res.code
    assert res.message =~ /command not found/
    assert_equal nil, res.data
  end


end
end
end
