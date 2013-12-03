
require 'helper'

module Bixby
module Test

class TestAgent < TestCase

  def setup
    super
    ENV["BIXBY_HOME"] = nil
  end

  def teardown
    super
    ENV["BIXBY_HOME"] = nil
    ENV["BIXBY_LOG"] = nil
  end

  def test_create_new_agent
    @agent = create_new_agent()
    @agent.save_config()
    assert(@agent.new?)
    assert( File.exists? File.join(@root_dir, "etc", "bixby.yml") )
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir

    assert_equal 2, Logging::Logger.root.level # default is warn
  end

  def test_load_existing_agent
    setup_existing_agent()
    @agent = create_new_agent()
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir

    assert_equal 1, Logging::Logger.root.level # info level is in yaml
  end

  def test_load_existing_agent_override_log
    ENV["BIXBY_LOG"] = "debug"
    setup_existing_agent()
    @agent = create_new_agent()
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir

    assert_equal 0, Logging::Logger.root.level
  end

  def test_load_existing_agent_using_env
    setup_existing_agent()
    ENV["BIXBY_HOME"] = @root_dir

    @agent = Agent.create()
    assert @agent
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir
    assert_equal @root_dir, Bixby.root
  end

  def test_create_missing_manager_uri
    @manager_uri = nil
    assert_throws(ConfigException) do
      @agent = create_new_agent()
    end
  end

  def test_create_with_bad_manager_uri
    @manager_uri = "asdf"
    assert_throws(ConfigException) do
      @agent = create_new_agent()
    end
  end

  def test_register_with_manager
    @agent = create_new_agent()

    response_str = MultiJson.dump({
                      :data => {:server_key => "-----BEGIN RSA PUBLIC KEY-----",
                                :access_key => "foo",
                                :secret_key => "bar"},
                      :code    => nil,
                      :status  => "success",
                      :message => nil })

    # stub out http request
    stub_request(:post, "#{@manager_uri}/api").with { |req|
      req.body =~ /inventory:register_agent/ and req.body =~ /"tenant":"pixelcop"/

    }.to_return(:body => response_str, :status => 200)

    response = @agent.register_agent
    assert response.status == "success"

    key_file = Bixby.path("etc", "server.pub")
    assert File.exists? key_file
    assert File.read(key_file).include? "PUBLIC KEY"

    assert_equal "foo", @agent.access_key
    assert_equal "bar", @agent.secret_key
  end

  def test_bad_config
    setup_existing_agent()
    File.open(config_file(), 'w') { |f| f.write("foo") }
    assert_throws(SystemExit) do
      Agent.create
    end
  end


  private

  def config_file
    File.join(@root_dir, "etc", "bixby.yml")
  end

end

end
end
