
# Main God config
#
# usage:
#
#   # god -P var/bixby-god.pid -c etc/bixby.god
#
# god must be run as root!
#
# see also: http://godrb.com/

BIXBY_HOME   = ENV["BIXBY_HOME"] || "/opt/bixby"
BIXBY_CLIENT = File.join(BIXBY_HOME, "bin", "bixby")

God.pid_file_directory = File.join(BIXBY_HOME, "var", "pids")

path = File.join(BIXBY_HOME, "etc", "god.d", "*.god")
Dir.glob(path).each do |conf|
  God.load conf
end
