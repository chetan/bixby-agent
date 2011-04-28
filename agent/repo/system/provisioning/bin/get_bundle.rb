#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), "/../../../../lib/agent"))
require AGENT_ROOT + "/server/json_request"
require AGENT_ROOT + "/server/json_response"

require 'digest'
require 'fileutils'

class Provision < BundleCommand

    include HttpClient

    def initialize
        super
    end

    def run!

        begin
            cmd = Command.from_json(ARGV.join(" "))
        rescue Exception => ex
            puts "failed"
            exit
        end

        files = list_files(cmd)
        download_files(cmd, files)

    end

    def list_files(cmd)

        req = JsonRequest.new("provisioning:list_files", cmd.to_hash)
        res = JsonResponse.from_json(http_post_json(api_url, req.to_json))
        return res.data
    end

    def download_files(cmd, files)
        local_path = cmd.bundle_dir
        sha = Digest::SHA1.new
        p local_path
        files.each do |f|
            # see if the file already exists
            path = File.join(local_path, f['file'])
            FileUtils.mkdir_p(File.dirname(path))
            # puts path
            next if File.file? path and f['sha1'] == sha.hexdigest(File.read(path))
            # puts "downloading file"
            req = JsonRequest.new("provisioning:fetch_file", { :cmd => cmd.to_hash, :file => f['file'] })
            http_post_download(api_url, req.to_json, path)
            if f['file'] =~ /^bin/ then
                # correct permissions for executables
                FileUtils.chmod(0755, path)
            end
        end
    end

    def api_url
        @agent.manager_uri + "/api"
    end

end

Provision.new.run!