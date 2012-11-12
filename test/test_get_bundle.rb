
require 'helper'

module Bixby
module Test

class GetBundle < TestCase

  def setup
    super
    setup_test_bundle("local", "system/provisioning", "get_bundle.rb")
    @agent = Agent.create(@manager_uri, @tenant, @password, @root_dir, @port)
    Agent.stubs(:create).returns(@agent)
  end

  def test_get_bundle

    assert @c.command_file
    assert File.exists? @c.command_file

    begin
        require @c.command_file
    rescue Exception => ex
    end

    # test our stub
    a = Agent.create
    assert_equal @agent, a

    cmd = CommandSpec.new({
        :repo => "support",
        :bundle => "test_bundle",
        :command => "echo",
        :digest => "c1af0e59a74367e83492a7501f6bdd7ed33de005c3f727a302c5ddfafa8c6f70" })

    cmd_hash = MultiJson.load(cmd.to_json)
    provisioner = Provision.new
    provisioner.stubs(:get_json_input).returns(cmd_hash.dup, cmd_hash.dup)

    # setup our expectations on the run method
    ret_list = JsonResponse.from_json('{"status":"success","message":null,"data":[{"file":"bin/echo","digest":"abcd"}],"code":null}')
    a.expects(:exec_api).once().returns(ret_list)
    a.expects(:exec_api_download).once().with{ |req, filename|
        dir = File.dirname(filename)
        assert File.exists? dir
        assert File.directory? dir
        `cp -a #{@bundle_path} #{@root_dir}/repo/support/` # copy whole bundle
        true
        }.returns(true)

    provisioner.run

    assert File.exists? cmd.command_file
    assert File.file? cmd.command_file
    assert File.executable? cmd.command_file

    # a second run shouldn't do anything since digests already match
    provisioner.run
  end

  def test_bad_json

    begin
        require @c.command_file
    rescue Exception => ex
    end

    # test our stub
    a = Agent.create
    assert_equal @agent, a

    provisioner = Provision.new
    provisioner.stubs(:get_json_input).returns(nil)

    assert_throws(SystemExit) do
      provisioner.run
    end

  end

end

end
end
