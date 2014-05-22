
require 'facter'
require 'uuidtools'

require "bixby-agent/agent/crypto"

module Bixby
class Agent

module Handshake

  include Crypto

  # Register the agent with the server
  #
  # @return [JsonResponse] response from server
  def register_agent(tags=nil)
    ret = Bixby::Inventory.register_agent({
      :uuid       => @uuid,
      :public_key => self.public_key.to_s,
      :hostname   => get_hostname(),
      :tenant     => @tenant,
      :password   => @password,
      :tags       => tags,
      :version    => Bixby::Agent::VERSION
      })

    if ret.fail? then
      return ret
    end

    @access_key = ret.data["access_key"]
    @secret_key = ret.data["secret_key"]

    # success, store server's pub key
    File.open(self.server_key_file, 'w') do |f|
      f.puts(ret.data["server_key"])
    end

    return ret
  end

  def mac_changed?
    (not @mac_address.nil? and (@mac_address != get_mac_address()))
  end

  def get_hostname
    `hostname`.strip
  end

  # Get the mac address of the system's primary interface
  def get_mac_address
    return @mac if not @mac.nil?
    Facter.collection.fact(:ipaddress).value # force value to be loaded now (usually lazy-loaded)
    Facter.collection.fact(:interfaces).value
    Facter.collection.fact(:macaddress).value
    vals = Facter.collection.to_hash
    ip = vals["ipaddress"]
    raise "Unable to find IP address" if ip.nil?
    # use the primary IP of the system to find the associated interface name (e.g., en0 or eth0)
    int = vals.find{ |k,v| v == ip && k != "ipaddress" }.first.to_s.split(/_/)[1]
    raise "Unable to find primary interface" if int.nil? or int.empty?
    # finally, get the mac address
    @mac = vals["macaddress_#{int}"]
  end

  def create_uuid
    UUIDTools::UUID.random_create.hexdigest
  end

end # Handshake

end # Agent
end # Bixby
