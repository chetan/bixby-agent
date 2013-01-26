
require 'helper'

module Bixby
module Test

class TestApp < TestCase

  def test_load_agent
    ARGV.clear
    ARGV << "-d"
    ARGV << @root_dir
    ARGV << @manager_uri

    response_str = MultiJson.dump({
                      :data => {:server_key => "-----BEGIN RSA PUBLIC KEY-----",
                                :access_key => "foo",
                                :secret_key => "bar"},
                      :code    => nil,
                      :status  => "success",
                      :message => nil })

    stub_request(:post, "http://localhost:3000/api").
      to_return(:status => 200, :body => response_str)

    app = App.new
    app.load_agent()

    assert_requested(:post, @manager_uri + "/api", :times => 1)
    conf_file = File.join(@root_dir, "etc", "bixby.yml")
    assert File.exists? conf_file
    assert File.exists? File.join(@root_dir, "etc", "server.pub")

    conf = File.read(conf_file)
    assert conf
    assert_includes conf, "access_key"
    assert_includes conf, "secret_key"
    assert_includes conf, "log_level"
    assert_includes conf, "foo"
  end

  def test_missing_manager_uri
    ARGV.clear
    ARGV << "-d"
    ARGV << @root_dir

    app = App.new
    assert_throws(SystemExit) do
      app.load_agent()
    end
  end

  def test_register_failed

    ARGV.clear
    ARGV << "-d"
    ARGV << @root_dir
    ARGV << @manager_uri

    stub_request(:post, "http://localhost:3000/api").to_return(:status => 200, :body => MultiJson.dump({:status => "fail"}))

    app = App.new
    assert_throws(SystemExit) do
      app.load_agent()
    end

  end

  def test_setup_logger
    ARGV.clear
    ENV.delete("BIXBY_DEBUG")
    ARGV << "--debug"
    app = App.new
    Bixby::Agent.setup_logger
    assert_equal 0, Logging::Logger.root.level # debug

    ENV.delete("BIXBY_DEBUG")
    ARGV.clear
    app = App.new
    Bixby::Agent.setup_logger
    assert_equal 2, Logging::Logger.root.level # warn

    ENV.delete("BIXBY_DEBUG")
    ARGV.clear
    setup_existing_agent()

    assert_equal 1, Logging::Logger.root.level # info
  end

end

end
end
