
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
    log.debug { "shell_exec:\n" + spec.to_s + "\n" }
    spec.validate(digest)

    cmd = "#{spec.command_file} #{spec.args}"

    # Cleanup the ENV and execute
    old_env = {}
    %W{BUNDLE_BIN_PATH BUNDLE_GEMFILE}.each{ |r|
      old_env[r] = ENV.delete(r) if ENV.include?(r) }

    logger.debug("exec: #{cmd}")
    shell = Mixlib::ShellOut.new(cmd, :input => spec.stdin,
                                      :user  => uid(spec.user),
                                      :group => gid(spec.group))

    shell.run_command

    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    return CommandResponse.new({ :status => shell.exitstatus,
                                 :stdout => shell.stdout,
                                 :stderr => shell.stderr })
  end


  private

  # Return uid of 'bixby' user, if it exists
  #
  # @param [String] user        username to run as [Optional, default=bixby]
  # @return [Fixnum]
  def uid(user)
    if Process.uid != 0 then
      logger.warn("Can't change effective uid unless running as root")
      return nil
    end

    if user then
      begin
        return Etc.getpwnam(user).uid
      rescue ArgumentError => ex
        logger.warn("Username '#{user}' was invalid: #{ex.message}")
      end
    end

    begin
      return Etc.getpwnam("bixby").uid
    rescue ArgumentError
    end
    return nil
  end

  # Return uid of 'bixby' group, if it exists
  #
  # @param [String] group         group to run as [Optional, default=bixby]
  # @return [Fixnum]
  def gid(group)
    if Process.uid != 0 then
      logger.warn("Can't change effective gid unless running as root")
      return nil
    end

    if group then
      begin
        return Etc.getgrnam(group).uid
      rescue ArgumentError => ex
        logger.warn("Group '#{group}' was invalid: #{ex.message}")
      end
    end

    begin
      return Etc.getgrnam("bixby").gid
    rescue ArgumentError
    end
    return nil
  end

end # Exec

end # Agent
end # Bixby
