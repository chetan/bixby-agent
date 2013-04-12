
require 'helper'

module Bixby
module Test

class TestAgent < TestCase

  def setup
    super
    ENV["BIXBY_HOME"] = nil
  end

  def test_create_new_agent
    @agent = create_new_agent()
    @agent.save_config()
    assert(@agent.new?)
    assert( File.exists? File.join(@root_dir, "etc", "bixby.yml") )
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir

    # make sure logger was setup properly
    assert Logging::Logger.root.level > 1
  end

  def test_load_existing_agent
    setup_existing_agent()
    @agent = create_new_agent()
    assert(!@agent.new?)
    assert ENV["BIXBY_HOME"]
    assert_equal ENV["BIXBY_HOME"], @root_dir
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
      req.body =~ /inventory:register_agent/ and req.body =~ /"port":9999,"tenant":"pixelcop"/

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
