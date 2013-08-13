
require 'mixlib/shellout'

module Bixby
class Agent

module ShellExec

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
  # @return [CommandResponse]
  #
  # @raise [BundleNotFound] If bundle doesn't exist or digest does not match
  # @raise [CommandNotFound] If command doesn't exist
  def shell_exec(params)
    digest = params.delete("digest") || params.delete(:digest)

    spec = CommandSpec.new(params)
    debug { "shell_exec:\n" + spec.to_s + "\n" }
    spec.validate(digest)

    cmd = "#{spec.command_file} #{spec.args}"

    # Cleanup the ENV and execute
    rem = [ "BUNDLE_BIN_PATH", "BUNDLE_GEMFILE" ] # "RUBYOPT"
    old_env = {}
    rem.each{ |r| old_env[r] = ENV.delete(r) }

    shell = Mixlib::ShellOut.new(cmd, :input => spec.stdin)
    shell.run_command

    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    return CommandResponse.new({ :status => shell.exitstatus,
                                 :stdout => shell.stdout,
                                 :stderr => shell.stderr })
  end

end # Exec

end # Agent
end # Bixby
