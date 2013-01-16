#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup(:default)

$: << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'bixby_agent'
require 'bixby_agent/app'

Bixby::App.new.run!
