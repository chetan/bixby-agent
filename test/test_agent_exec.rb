
require 'helper'

module Bixby
module Test

class AgentExec < TestCase

  def setup
    super
    setup_test_bundle("support", "test_bundle", "echo")
    @agent = Agent.create(@manager_uri, @password, @root_dir, @port)
  end

  def setup_root
    # copy repo to path
    `mkdir -p #{@root_dir}/repo/support`
    `cp -a #{@bundle_path} #{@root_dir}/repo/support/`
  end

  def test_exec_error
    # throws the first time
    assert_throws(BundleNotFound) do
      @agent.exec(@c.to_hash)
    end
  end

  def test_exec_pass
    setup_root()
    (status, stdout, stderr) = @agent.exec(@c.to_hash)
    assert status
    assert status.kind_of? Fixnum
    assert_equal 0, status
    assert stdout
    assert stderr
    assert_equal("hi\n", stdout)
    assert_equal("", stderr)
  end

  def test_execute_stdin
    setup_root()
    @c.command = "cat"
    @c.stdin = "hi"
    (status, stdout, stderr) = @agent.exec(@c.to_hash)
    assert_equal 0, status
    assert_equal("hi", stdout)
    assert_equal("", stderr)
  end


end

end
end
