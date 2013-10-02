
require 'helper'

module Bixby
module Test

class AgentExec < TestCase

  def setup
    super
    setup_test_bundle("support", "test_bundle", "echo",
      "c1af0e59a74367e83492a7501f6bdd7ed33de005c3f727a302c5ddfafa8c6f70")
    @agent = create_new_agent()
  end

  def test_exec_error
    # throws the first time
    assert_throws(BundleNotFound) do
      @agent.shell_exec(@c.to_hash)
    end
  end

  def test_exec_pass
    setup_root()
    @c.args = "foo bar baz"
    @c.user = `whoami`.strip
    @c.group = `groups`.strip.split(/ /).first
    ret = @agent.shell_exec(@c.to_hash)
    assert ret
    assert_kind_of CommandResponse, ret
    assert_kind_of Fixnum, ret.status
    assert_equal 0, ret.status
    assert ret.stdout
    assert ret.stderr
    assert_equal "foo bar baz\n", ret.stdout
    assert_equal "", ret.stderr
  end

  def test_execute_stdin
    setup_root()
    @c.command = "cat"
    @c.stdin = "hi"
    ret = @agent.shell_exec(@c.to_hash)
    assert_equal 0, ret.status
    assert_equal "hi", ret.stdout
    assert_equal "", ret.stderr
  end


end

end
end
