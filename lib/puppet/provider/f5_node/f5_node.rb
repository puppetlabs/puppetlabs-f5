require 'puppet/provider/f5'

Puppet::Type.type(:f5_node).provide(:f5_node, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 node"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.NodeAddress'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'dynamic_ratio',
    'monitor_state',
    'ratio',
    'screen_name',
    'session_enabled_state']

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        transport[wsdl].send("get_#{method}", resource[:name]).first
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

  def monitor_association
    transport[wsdl].get_monitor_association(resource[:name])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Node: creating F5 node #{resource[:name]}")
    transport[wsdl].create(resource[:name], resource[:connection_limit])

    # need to sync all attributes afterwards
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Pool: destroying F5 node #{resource[:name]}")
    transport[wsdl].delete_node_address(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
