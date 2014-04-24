require 'puppet/provider/f5'

Puppet::Type.type(:f5_virtualaddress).provide(:f5_virtualaddress, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 virtual address"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.VirtualAddress'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'arp_state',
    'enabled_state',
    'is_floating_state',
    'route_advertisement_state',
    'status_dependency_scope']

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        transport[wsdl].send("get_#{method}", resource[:name]).first.to_s
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", resource[:name], resource[method.to_sym])
      end
    end
  end

  def connection_limit
    val = transport[wsdl].get_connection_limit(resource[:name]).first
    to_64s(val)
  end

  def connection_limit=(value)
    transport[wsdl].set_connection_limit(resource[:name], [ to_32h(resource[:connection_limit]) ])
  end

  def create
    # Virtual addresses can't be created, they appear when a virtual server with that address is
    # created.  Therefore, we only set stuff here.

    methods = [ 'arp_state',
      'enabled_state',
      'is_floating_state',
      'route_advertisement_state',
      'status_dependency_scope']

    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VirtualAddress: destroying F5 virtual address #{resource[:name]}")
    transport[wsdl].delete_virtual_address(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
