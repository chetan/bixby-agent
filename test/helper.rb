require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test_guard'
TestGuard.load_simplecov()

# load curb first so webmock can stub it out as necessary
require 'curb'
require 'webmock'
include WebMock::API
require 'mocha'

$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib')))
ENV["RUBYLIB"] = $:.first
require 'bixby_agent'

require "base"
Dir.glob(File.dirname(__FILE__) + "/../lib/**/*.rb").each{ |f| require f }
MiniTest::Unit.autorun
