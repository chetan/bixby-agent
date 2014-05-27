
module Bixby
  module Help
    class SystemTime

      extend Bixby::Script::Distro
      extend Bixby::Script::Platform

      def self.print
        $stderr.puts self.message
      end

      # Registration may fail if the system clock is too far in the past (more than 15 minutes)
      # Show the user how to fix the issue and try again
      def self.message
        s = "  it appears your system clock is out of sync"

        res = HTTPI.get("http://google.com")
        if not res.error? then
          current_time = Time.parse(res.headers["Date"]).utc
          s += "  > current time: #{current_time}"
          s += "  >  system time: #{Time.new.utc}"
        end

        $stderr.puts
        if linux? && ubuntu? then
          s += "  to fix:"
          s += "  sudo apt-get install ntpdate && sudo ntpdate ntp.ubuntu.com"
        elsif linux? && centos? then
          s += "  to fix:"
          s += "  sudo yum install ntpdate && sudo ntpdate ntp.ubuntu.com"
        else
          s += "  you can fix this on most unix systems by running 'sudo ntpdate ntp.ubuntu.com'"
        end

        s
      end

    end
  end
end
