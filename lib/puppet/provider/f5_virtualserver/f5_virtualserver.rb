require 'puppet/provider/f5'

Puppet::Type.type(:f5_virtualserver).provide(:f5_virtualserver, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 device"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.VirtualServer'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  def availability_status
    status = transport[wsdl].get_object_status(resource[:name])
    status[0].availability_status
  end

  def enabled_status
    status = transport[wsdl].get_object_status(resource[:name])
    status[0].enabled_status
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying F5 virtual server #{resource[:name]}")
    transport[wsdl].create(resource[:name])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying F5 virtual server #{resource[:name]}")
    transport[wsdl].delete_virtual_server(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
