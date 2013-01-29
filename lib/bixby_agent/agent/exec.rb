
require 'systemu'

module Bixby
class Agent

module Exec

  # Shell exec a local command with the given params
  #
  # @param [Hash] params                  CommandSpec hash
  # @option params [String] :repo
  # @option params [String] :bundle
  # @option params [String] :command
  # @option params [String] :args
  # @option params [String] :stdin
  # @option params [String] :digest       Expected bundle digest
  # @option params [Hash] :env            Hash of extra ENV key/values to pass to sub-shell
  #
  # @return [Array<FixNum, String, String>] status code, stdout, stderr
  # @raise [BundleNotFound] If bundle doesn't exist or digest does not match
  # @raise [CommandNotFound] If command doesn't exist
  def exec(params)
    digest = params.delete("digest") || params.delete(:digest)

    spec = CommandSpec.new(params)
    spec.validate(digest)

    cmd = "#{spec.command_file} #{spec.args}"
    debug { "cmd: #{cmd}" }

    # Cleanup the ENV and execute
    rem = [ "BUNDLE_BIN_PATH", "BUNDLE_GEMFILE" ] # "RUBYOPT"
    old_env = {}
    rem.each{ |r| old_env[r] = ENV.delete(r) }
    status, stdout, stderr = systemu(cmd, :stdin => spec.stdin)
    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    ret = [ status.exitstatus, stdout, stderr ]
    debug { "ret: " + MultiJson.dump(ret) }
    return ret
  end

end # Exec

end # Agent
end # Bixby
