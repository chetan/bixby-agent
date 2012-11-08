#!/usr/bin/env ruby

require 'rubygems'

begin
  require "bundler"
rescue Exception => ex
  if not Object.const_defined? :Bundler then
    # load from vendored path
    require 'pathname'
    $: << File.join(File.expand_path(File.dirname(Pathname.new(__FILE__).realpath)), "../vendor/cache/bundler-1.2.1/lib")
    require "bundler"
  end
end
Bundler.setup(:default)

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'bixby_agent'
require 'bixby_agent/app'

Bixby::App.new.run!
