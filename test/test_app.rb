
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

    # stub out daemons & sinatra server
    Daemons.expects(:daemonize).once().with{ |opts|
      opts.kind_of?(Hash) && opts[:app_name] == "bixby_agent" &&
        opts[:dir] == File.join(@root_dir, "var")
    }

    Bixby::Server.expects(:run!).once()

    app = App.new.run!

    assert_requested(:post, @manager_uri + "/api", :times => 1)
    conf_file = File.join(@root_dir, "etc", "bixby.yml")
    assert File.exists? conf_file
    assert File.exists? File.join(@root_dir, "etc", "server.pub")

    # verify yaml config file
    conf = File.read(conf_file)
    assert conf
    assert_includes conf, "uuid"
    assert_includes conf, "mac_address"
    assert_includes conf, "access_key"
    assert_includes conf, "secret_key"
    assert_includes conf, "log_level"
    Bixby::Agent::Config::KEYS.each{ |k| assert_includes conf, k }

    assert_includes conf, "foo"
    assert_includes conf, "bar"
    assert_kind_of Hash, YAML.load(conf)
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

end

end
end
