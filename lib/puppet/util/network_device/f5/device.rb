require 'uri'
require 'puppet/util/network_device/f5/facts'
require 'puppet/util/network_device/f5/transport'

class Puppet::Util::NetworkDevice::F5::Device

  attr_accessor :url, :transport, :partition

  def initialize(url, option = {})
    @url = URI.parse(url)
    @option = option

    modules = [
      'LocalLB.Class',
      'LocalLB.Monitor',
      'LocalLB.NodeAddressV2',
      'LocalLB.ProfileClientSSL',
      'LocalLB.ProfilePersistence',
      'LocalLB.Pool',
      'LocalLB.PoolMember',
      'LocalLB.Rule',
      'LocalLB.SNAT',
      'LocalLB.SNATPool',
      'LocalLB.SNATTranslationAddressV2',
      'LocalLB.VirtualServer',
      'Management.KeyCertificate',
      'Management.Partition',
      'Management.SNMPConfiguration',
      'Management.UserManagement',
      'Networking.RouteTableV2',
      'Networking.SelfIPV2',
      'Networking.VLAN',
      'System.ConfigSync',
      'System.Inet',
      'System.Session',
      'System.SystemInfo'
    ]

    Puppet.debug("Puppet::Device::F5: connecting to F5 device #{@url.host}.")
    @transport ||= Puppet::Util::NetworkDevice::F5::Transport.new(@url.host, @url.user, @url.password, modules).get_interfaces

    # Access Common folder by default:
    if @url.path == '' or @url.path == '/'
      @folder = '/Common'
    else
      @folder = /(\/.*)/.match(@url.path).captures
    end

    # System.Session API not supported until V11.
    Puppet.debug("Puppet::Device::F5: connecting to partition #{@folder}.")

    # System.Session is only available on F5 11.0
    transport['System.Session'].call(:set_active_folder, message: { folder: @folder })
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::F5::Facts.new(@transport)
    facts = @facts.retrieve

    # inject F5 partition info.
    facts['partition'] = @partition
    facts
  end
end
