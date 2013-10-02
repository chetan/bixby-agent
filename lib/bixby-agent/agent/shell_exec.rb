
require 'mixlib/shellout'

module Bixby
class Agent

module ShellExec

  class Platform
    extend Bixby::PlatformUtil
  end

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
                                      :user  => get_id(spec.user, "user"),
                                      :group => get_id(spec.group, "group"))

    shell.run_command

    old_env.each{ |k,v| ENV[k] = v } # reset the ENV

    return CommandResponse.new({ :status => shell.exitstatus,
                                 :stdout => shell.stdout,
                                 :stderr => shell.stderr })
  end



  private

  # Lookup a user or group name and return the ID
  #
  # @param [String] str
  # @param [String] type        "user" or "group"
  #
  # @return [Fixnum]
  def get_id(str, type)
    return str if str.nil? or str.kind_of? Fixnum

    # use getent on linux
    if Platform.linux? then
      file = (type == "user" ? "passwd" : "group")
      cmd = Mixlib::ShellOut.new("getent", file, str)
      cmd.run_command
      if cmd.success? then
        return cmd.stdout.split(/:/)[2]
      else
        return nil
      end

    # use dscl on darwin
    elsif Platform.darwin? then
      path = (type == "user" ? "/Users" : "/Groups")
      cmd = Mixlib::ShellOut.new("dscl . -read #{path}/#{str}")
      cmd.run_command
      if cmd.success? then
        if type == "user" && cmd.stdout =~ /^UniqueID: (\d+)/ then
          return $1.to_i
        elsif type == "group" && cmd.stdout =~ /^PrimaryGroupID: (\d+)/ then
          return $1.to_i
        end
      end
      return nil
    end

  end # get_id


end # Exec

end # Agent
end # Bixby
