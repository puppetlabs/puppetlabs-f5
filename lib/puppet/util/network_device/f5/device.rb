require 'uri'
require 'f5-icontrol'
# require 'puppet/util/network_device/base'
require 'puppet/util/network_device/f5/facts'

class Puppet::Util::NetworkDevice::F5::Device

  attr_accessor :url, :transport

  def initialize(url, option = {})
    @url = URI.parse(url)
    @option = option

    modules   = [ "LocalLB.NodeAddress",
                  "LocalLB.ProfileClientSSL",
                  "LocalLB.Pool",
                  "LocalLB.PoolMember",
                  "LocalLB.Rule",
                  "LocalLB.SNAT",
                  "LocalLB.SNATPool",
                  "LocalLB.SNATTranslationAddress",
                  "LocalLB.VirtualServer",
                  "Management.KeyCertificate",
                  "System.SystemInfo" ]

    @transport ||= F5::IControl.new(@url.host, @url.user, @url.password, modules).get_interfaces
  end

  def facts
    @facts ||= Puppet::Util::NetworkDevice::F5::Facts.new(@transport)
    @facts.retreive
  end
end
