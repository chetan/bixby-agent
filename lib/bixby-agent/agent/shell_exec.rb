
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
  # @option params [String] :user         User to run as
  # @option params [String] :group        Group to run as
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
    old_env = {}
    %W{BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each{ |r|
      old_env[r] = ENV.delete(r) if ENV.include?(r) }

    shell = Mixlib::ShellOut.new(cmd, :input => spec.stdin,
                                      :user  => (spec.user || default_uid),
                                      :group => (spec.group || default_gid))

    shell.run_command

    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    return CommandResponse.new({ :status => shell.exitstatus,
                                 :stdout => shell.stdout,
                                 :stderr => shell.stderr })
  end


  private

  # Return uid of 'bixby' user, if it exists
  #
  # @return [Fixnum]
  def default_uid
    begin
      return Etc.getpwnam("bixby").uid
    rescue ArgumentError
    end
    return nil
  end

  # Return uid of 'bixby' group, if it exists
  #
  # @return [Fixnum]
  def default_gid
    begin
      return Etc.getgrnam("bixby").gid
    rescue ArgumentError
    end
    return nil
  end

end # Exec

end # Agent
end # Bixby
