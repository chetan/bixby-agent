
require 'helper'

module Bixby
module Test

class Crypto < TestCase

  def test_keygen
    create_new_agent()

    assert File.exists? @agent.private_key_file
    assert @agent.private_key
    assert @agent.public_key
  end

  def test_server_key
    setup_existing_agent()

    assert @agent.have_server_key?
    assert @agent.server_key
    assert @agent.encrypt_for_server("foobar")
  end

  def test_decrypt
    setup_existing_agent()
    input = encrypt_for_agent("foobar")
    assert_equal "foobar", @agent.decrypt_from_server(input)
  end

  def test_decrypt_invalid_hmac
    setup_existing_agent()
    input = encrypt_for_agent("foobar")

    # mangle the hmac
    s = StringIO.new(input)
    test = s.readline
    test += "32" + s.readline
    test += s.read

    assert_throws Bixby::EncryptionError, "hmac verification failed" do
      @agent.decrypt_from_server(test)
    end
  end

  # This test is the same as Bixby::Test::Provisioning.test_list_files except
  # that crypto routines are enabled.
  def test_api_call_with_crypto

    setup_test_bundle("vendor", "system/provisioning", "get_bundle.rb")
    begin
      require @c.command_file
    rescue Bixby::ConfigException
    end
    ENV["BIXBY_NOCRYPTO"] = "0"
    setup_existing_agent()

    stub_request(:post, @api_url).with { |req|
      req.headers.include?("Authorization") &&
        req.headers.include?("Date") &&
        req.headers.include?("Content-Md5") &&
        req.body =~ /operation/ && req.body =~ /test_bundle/
    }.to_return(:status => 200, :body => JsonResponse.new(200, nil, {:foo => "bar"}).to_json)
    Agent.stubs(:create).returns(@agent)

    cmd = CommandSpec.new({ :repo => "support", :bundle => "test_bundle", :command => "echo" })
    ret = Bixby::Repository.list_files(cmd)
    assert ret
    assert_kind_of Hash, ret
    assert_equal "bar", ret["foo"]
  end

end

end
end
