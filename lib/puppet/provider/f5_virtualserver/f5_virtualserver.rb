require 'f5-icontrol'
require 'util/network_device/f5.rb'

Puppet::Type.type(:f5_virtualserver).provide(:f5_virtualserver, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 device"

  confine :feature => :posix
  defaultfor :feature => :posix

  F5_WSDL = 'LocalLB.VirtualServer'

  def self.instances
    transport[F5_WSDL].get_list.collect do |name|
      new(:name => name)
    end
  end

  def availability_status
    status = transport[F5_WSDL].get_object_status(resource[:name])
    status[0].availability_status
  end

  def enabled_status
    status = transport[F5_WSDL].get_object_status(resource[:name])
    status[0].enabled_status
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying F5 virtual server #{resource[:name]}")
    transport[F5_WSDL].create(resource[:name])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying F5 virtual server #{resource[:name]}")
    transport[F5_WSDL].delete_virtual_server(resource[:name])
  end

  def exists?
    transport[F5_WSDL].get_list.include?(resource[:name])
  end
end
