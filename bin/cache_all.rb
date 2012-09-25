#!/usr/bin/env ruby

require 'rubygems'
require 'bundler'
require 'fileutils'

ROOT = File.expand_path(File.dirname(File.dirname(__FILE__)))
VENDOR = File.join(ROOT, "vendor/cache/")

FileUtils.mkdir_p(VENDOR)


start = false
gems = []
File.open(File.join(ROOT, "Gemfile.lock")).each do |line|

  if line.strip == "GEM" then
    start = true
    next
  elsif line.strip == "PLATFORMS" then
    break
  end

  next if not start

  if line =~ /^    (.*?) \((.*?)\)$/ then
    (g, v) = [$1, $2]
    next if g =~ /^  /
    gems << Gem::Specification.new(g, v)
  end

end



gems.each do |spec|
  gem_path = "#{Bundler.rubygems.gem_dir}/cache/#{spec.full_name}.gem"
  if not File.exist? gem_path then
    `gem fetch -v #{spec.version} #{spec.name}`
    `mv ./#{spec.name}-#{spec.version}.gem #{VENDOR}`
    next
  end
  if not File.exist? File.join(VENDOR, File.basename(gem_path)) then
    FileUtils.cp gem_path, VENDOR
  end
end

`gem fetch rubygems-update -q`
`mv ./rubygems-update-*.gem #{VENDOR}`

exit

# this only works for platform specific gems (the current platform)
Bundler.setup.specs.to_a.each do |spec|
  gem_path = "#{Bundler.rubygems.gem_dir}/cache/#{spec.full_name}.gem"

  if spec.source.kind_of? Bundler::Source::Rubygems then
    if not File.exist? gem_path then
      Bundler::Fetcher.fetch(spec)
    end
    if not File.exist? File.join(VENDOR, File.basename(gem_path)) then
      FileUtils.cp gem_path, VENDOR
    end
  end

end
