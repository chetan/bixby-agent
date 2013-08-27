
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
      :port       => @port,
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

  def get_mac_address
    return @mac if not @mac.nil?
    Facter.collection.loader.load(:ipaddress)
    Facter.collection.loader.load(:interfaces)
    Facter.collection.loader.load(:macaddress)
    vals = {}
    Facter.collection.list.each { |n| vals[n] = Facter.collection[n] }
    ip = vals[:ipaddress]
    raise "Unable to find IP address" if ip.nil?
    int = vals.find{ |k,v| v == ip && k != :ipaddress }.first.to_s.split(/_/)[1]
    raise "Unable to find primary interface" if int.nil? or int.empty?
    @mac = vals["macaddress_#{int}".to_sym]
  end

  def create_uuid
    UUIDTools::UUID.random_create.hexdigest
  end

end # Handshake

end # Agent
end # Bixby