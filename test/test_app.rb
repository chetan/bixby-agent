
require 'helper'
require 'timeout'

module Bixby
module Test

class TestApp < TestCase

  def teardown
    ENV["BIXBY_LOG"] = nil
  end

  def test_load_agent
    ARGV.clear
    ARGV << "--register" << @manager_uri
    ARGV << "-d" << @root_dir
    ARGV << "--tenant" << "mytenant"
    ARGV << "--password" << "mypass"

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
    Daemons.expects(:run_proc).once().with{ |name,opts|
      name == "bixby-agent" && opts.kind_of?(Hash) &&
        opts[:dir] == File.join(@root_dir, "var")
    }

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

  def test_run_agent

    ARGV.clear
    ARGV << "--register" # uri should default to bixby.io
    ARGV << "--debug"
    ARGV << "--directory" << @root_dir
    ARGV << "--tenant" << "mytenant"
    ARGV << "--password" << "mypass"

    Bixby::WebSocket::Client.any_instance.expects(:start).once()

    response_str = MultiJson.dump({
                      :data => {:server_key => "-----BEGIN RSA PUBLIC KEY-----",
                                :access_key => "foo",
                                :secret_key => "bar"},
                      :code    => nil,
                      :status  => "success",
                      :message => nil })

    stub_request(:post, "https://bixby.io/api").
      to_return(:status => 200, :body => response_str)

    App.new.run!

    assert_equal "debug", ENV["BIXBY_LOG"]
  end

  def test_run_with_bad_manager_uri
    ARGV.clear
    ARGV << "--register" << "asdf"
    ARGV << "-d" << @root_dir

    assert_throws(ConfigException) do
      App.new.run!
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

  def test_register_agent_with_old_date

    ARGV.clear
    ARGV << "--register" # uri should default to bixby.io
    ARGV << "--debug"
    ARGV << "--directory" << @root_dir
    ARGV << "--tenant" << "mytenant"
    ARGV << "--password" << "mypass"

    stub_request(:get, "http://google.com/").to_return(:status => 200, :body => "", :headers => {"Date" => (Time.new+1).utc.to_s})

    ret = Bixby::JsonResponse.new("fail", "request is more than 900 seconds old", nil, 401).to_json
    stub_request(:post, "https://bixby.io/api").
      to_return(:status => 200, :body => ret)

    assert_output(nil, /current time.*sudo ntpdate/m) do
      assert_throws(SystemExit) do
        App.new.run!
      end
    end
  end

end

end
end
