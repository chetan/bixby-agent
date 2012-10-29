
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

    cmd = CommandSpec.new(params)
    cmd.validate(digest)

    ret = execute(cmd)
    @log.debug{ "ret: " + MultiJson.dump(ret) }
    return ret
  end


  private

  # Execute this command
  #
  # @param [CommandSpec] spec  command to execute
  #
  # @return [Array<FixNum, String, String>] status code, stdout, stderr
  def execute(spec)
    if not (spec.stdin.nil? || spec.stdin.empty?) then
      temp = Tempfile.new("input-")
      temp << spec.stdin
      temp.flush
      temp.close
      cmd = "sh -c 'cat #{temp.path} | #{spec.command_file}"
    else
      cmd = "sh -c '#{spec.command_file}"
    end
    cmd += @args ? " #{spec.args}'" : "'"

    # Cleanup the ENV before executing command
    rem = [ "BUNDLE_BIN_PATH", "BUNDLE_GEMFILE", "RUBYOPT" ]
    old_env = {}
    rem.each{ |r| old_env[r] = ENV.delete(r) }
    status, stdout, stderr = systemu(cmd)
    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    return [ status.exitstatus, stdout, stderr ]
  end


end # Exec

end # Agent
end # Bixby
