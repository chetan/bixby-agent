
require 'helper'

module Bixby
module Test

class Provisioning < TestCase

  def setup
    super
    @agent = Agent.create(@manager_uri, @tenant, @password, @root_dir, @port)
  end

  def test_list_files

    stub_request(:post, @api_url).to_return(:status => 200, :body => '{}')
    Agent.stubs(:create).returns(@agent)

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })
    Bixby::Repository.list_files(cmd)

    assert_requested(:post, @manager_uri + "/api", :times => 1) { |req|
      b = MultiJson.load(req.body)
      b.kind_of?(Hash) && b["params"]["command"] == "echo" && b["operation"] == "provisioning:list_files"
    }

  end

  def test_download_files

    Agent.stubs(:create).returns(@agent)

    path = File.join(@support_path, "test_bundle", "bin")
    sha = Digest::SHA2.new

    `mkdir -p #{@root_dir}/repo/support/test_bundle/`
    `cp -a #{path}/../ #{@root_dir}/repo/support/test_bundle/`

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })
    files = [
      { "file" => "bin/echo", "digest" => "foo" }, # force "changed" digest
      { "file" => "bin/cat", "digest" => "foo" },
      { "file" => "manifest.json", "digest" => sha.hexdigest(File.read("#{path}/../manifest.json")) }
    ]

    req1 = stub_request(:post, @api_url).with{ |req|
      b = MultiJson.load(req.body)
      b.kind_of?(Hash) && b["params"].last == "bin/echo" && b["operation"] == "provisioning:fetch_file"
      }.to_return(:status => 200, :body => File.new("#{path}/echo")).times(1)

    req2 = stub_request(:post, @api_url).with{ |req|
      b = MultiJson.load(req.body)
      b.kind_of?(Hash) && b["params"].last == "bin/cat" && b["operation"] == "provisioning:fetch_file"
      }.to_return(:status => 200, :body => File.new("#{path}/cat")).times(1)

    digest_file = File.join(@root_dir, "repo", "support", "test_bundle", "digest")
    digest_mtime = File::Stat.new(digest_file).mtime.to_i

    Bixby::Repository.download_files(cmd, files)

    assert_requested(req1)
    assert_requested(req2)
    # should not receive a request for manifest.json

    file1 = File.join(@root_dir, "repo", "support", "test_bundle", "bin", "echo")
    file2 = File.join(@root_dir, "repo", "support", "test_bundle", "bin", "cat")

    # verify that files got created and with correct permissions
    [ file1, file2 ].each do |file|
      assert File.exists? file
      assert_equal 33261, File.stat(file).mode
    end

    assert_equal sha.hexdigest(File.read("#{path}/echo")), sha.hexdigest(File.read(file1))
    assert_equal sha.hexdigest(File.read("#{path}/cat")), sha.hexdigest(File.read(file2))

    refute_equal digest_mtime, File::Stat.new(digest_file).mtime.to_i

  end

end

end
end
