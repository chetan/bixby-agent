
require 'helper'

module Bixby
  module Test

    class TestCase < MiniTest::Unit::TestCase

      def setup
        super
        WebMock.reset!

        @git_path = File.expand_path(File.join(File.dirname(__FILE__), ".."))
        @support_path = File.join(@git_path, "test", "support")

        @manager_uri = "http://localhost:3000"
        @tenant = "pixelcop"
        @password = "foobar"
        @root_dir = "/tmp/agent_test_temp"
        @port = 9999

        Bixby.manager_uri = @manager_uri
        @api_url = @manager_uri + "/api"
        `rm -rf #{@root_dir}`

        vendor_path = File.join(@root_dir, "repo", "vendor")
        `mkdir -p #{vendor_path}`
        `cp -a #{File.join(@git_path, "repo/vendor/*")} #{vendor_path}`

        ENV["BIXBY_NOCRYPTO"] = "1"
        ENV["BIXBY_HOME"] = @root_dir
        ARGV.clear
      end

      def teardown
        `rm -rf #{@root_dir}`
        @agent = nil
        ENV["BIXBY_HOME"] = nil
      end

      def setup_existing_agent
        ENV["BIXBY_HOME"] = @root_dir
        src = File.join(@support_path, "root_dir")
        dest = File.join(@root_dir, "etc")
        FileUtils.mkdir_p(dest)
        FileUtils.copy_entry(src, dest)
        @agent = Agent.create
      end

      def setup_root
        # copy repo to path
        `mkdir -p #{@root_dir}/repo/support`
        `cp -a #{@bundle_path} #{@root_dir}/repo/support/`
      end

      def setup_test_bundle(repo, bundle, command, digest=nil)
        @bundle_path = File.join(@support_path, "test_bundle")
        @c = CommandSpec.new({ :repo => repo, :bundle => bundle,
                :command => command, :digest => digest })
      end

      def create_new_agent
        ENV["BIXBY_HOME"] = nil
        @agent = Agent.create({
          :uri => @manager_uri, :tenant => @tenant,
          :password => @password, :root_dir => @root_dir,
          :port => @port
          })
      end


      # common routines for crypto tests

      def server_private_key
        s = File.join(@root_dir, "etc", "server")
        OpenSSL::PKey::RSA.new(File.read(s))
      end

      def encrypt_for_agent(msg)
        Bixby::CryptoUtil.encrypt(msg, "server_uuid", @agent.private_key, server_private_key)
      end

      def decrypt_from_agent(data)
        data = StringIO.new(data, 'rb')
        uuid = data.readline.strip
        Bixby::CryptoUtil.decrypt(data, server_private_key, @agent.private_key)
      end

    end

  end
end
