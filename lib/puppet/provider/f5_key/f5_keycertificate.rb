require 'f5-icontrol'
require 'util/network_device/f5.rb'

Puppet::Type.type(:f5_key).provide(:f5_key) do
  @doc = "Manages f5 cert"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Management.KeyCertificate'
  end

  def wsdl
    self.class.wsdl
  end

  extend Puppet::Util::NetworkDevice::F5
  include Puppet::Util::NetworkDevice::F5

  def self.instances
    bigip[wsdl].get_key_list.collect do |name|
      new(:name => name.first.key_info)
    end
  end

  def exists?
    bigip[wsdl].get_list.include?(resource[:name])
  end
end
