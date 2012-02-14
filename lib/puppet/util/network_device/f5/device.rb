require 'uri'
require 'f5-icontrol'
require 'puppet/util/network_device/f5/facts'

class Puppet::Util::NetworkDevice::F5::Device

  attr_accessor :url, :transport, :partition, :facts

  def initialize(url, option = {})
    @url = URI.parse(url)
    @option = option

    modules = [
      'LocalLB.Class',
      'LocalLB.Monitor',
      'LocalLB.NodeAddress',
      'LocalLB.Pool',
      'LocalLB.PoolMember',
      'LocalLB.ProfileClientSSL',
      'LocalLB.ProfilePersistence',
      'LocalLB.Rule',
      'LocalLB.SNAT',
      'LocalLB.SNATPool',
      'LocalLB.SNATTranslationAddress',
      'LocalLB.VirtualServer',
      'Management.KeyCertificate',
      'Management.Partition',
      'Management.Provision',
      'Networking.SelfIP',
      'Networking.VLAN',
      'System.ConfigSync',
      'System.Session',
      'System.SystemInfo'
    ]

    Puppet.debug("Puppet::Device::F5: connecting to F5 device #{@url.host}.")
    @transport ||= F5::IControl.new(@url.host, @url.user, @url.password, modules).get_interfaces

    # Access Common partition by default:
    if @url.path == '' or @url.path == '/'
      @partition = 'Common'
    else
      @partition = /\/(.*)/.match(@url.path).captures
    end

    # System.Session API not supported until V11.
    Puppet.debug("Puppet::Device::F5: connecting to partition #{@partition}.")
    if transport['System.Session']
      transport['System.Session'].set_active_folder(@partition)
    else
      transport['Management.Partition'].set_active_partition(@partition)
    end
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::F5::Facts.new(@transport)
    facts = @facts.retreive

    # inject F5 partition info.
    facts['partition'] = @partition
    facts
  end
end
