
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
                                      :env   => spec.env,
                                      :user  => lookup_id(:uid, spec.user),
                                      :group => lookup_id(:gid, spec.group))

    shell.run_command

    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    return CommandResponse.new({ :status => shell.exitstatus,
                                 :stdout => shell.stdout,
                                 :stderr => shell.stderr })
  end


  private

  # Lookup the id of the given user or group
  #
  # @param [Symbol] type          :uid or :gid
  # @param [String] str           user or group name [Optional, default=bixby]
  #
  # @return [Fixnum]
  def lookup_id(type, str=nil)
    if Process.uid != 0 then
      logger.warn("Can't change effective gid unless running as root")
      return nil
    end

    method = type == :uid ? :getpwnam : :getgrnam

    if !(str.nil? or str.empty?) then
      begin
        logger.debug "Running as #{type} '#{str}'"
        return Etc.send(method, str).send(type)
      rescue ArgumentError => ex
        logger.warn("#{type} lookup for '#{str}' failed: #{ex.message}")
      end
    end

    begin
      logger.debug "Running as #{type} 'bixby' (default)"
      return Etc.send(method, "bixby").send(type)
    rescue ArgumentError
    end
    return nil
  end

end # Exec

end # Agent
end # Bixby
