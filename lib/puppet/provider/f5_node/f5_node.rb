require 'puppet/provider/f5'

Puppet::Type.type(:f5_node).provide(:f5_node, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 node"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.NodeAddressV2'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    Puppet.debug("Puppet::Provider::F5_Node: instances")
    Array(transport[wsdl].get(:get_list)).collect do |item|
      new(:name   => item,
          :ensure => :present
         )
    end
  end

  methods = {
    'dynamic_ratio'     => 'dynamic_ratios',
    'ratio'             => 'ratios',
    'connection_limit'  => 'limits'
  }

  methods.each do |method, arg|
    define_method(method.to_sym) do
      transport[wsdl].get("get_#{method}".to_sym, { nodes: { item: resource[:name] }})
    end
    define_method("#{method}=") do |value|
      message = { nodes: { item: resource[:name] }, arg => { item: resource[method.to_sym] }}
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end 

  def session_enabled_state 
    message = { nodes: { item: resource[:name]}}
    value = transport[wsdl].call(:get_session_status, message: message).body[:get_session_status_response][:return][:item]

    case
    when value.match(/DISABLED$/)
      'STATE_DISABLED'
    when value.match(/ENABLED$/)
      'STATE_ENABLED'
    else
      nil
    end
  end

  def session_enabled_state=(value)
    message = { nodes: { item: resource[:name]}, states: { item: resource[:session_enabled_state]}}
    transport[wsdl].call(:set_session_enabled_state, message: message)
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Node: creating F5 node #{resource[:name]}")
    # The F5 API isn't consistent, it accepts long instead of ULong64 so we set connection limits later.
    message = { 
      nodes: { item: resource[:name] },
      addresses: { item: resource[:addresses] },
      limits: { item: resource[:connection_limit] }
    }
    transport[wsdl].call(:create, message: message)

    methods = [
      'connection_limit',
      'dynamic_ratio',
      'ratio',
      'session_enabled_state'
     ]

    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Pool: destroying F5 node #{resource[:name]}")
    transport[wsdl].call(:delete_node_address, message: { nodes: { item: resource[:name]}})
  end

  def exists?
    transport[wsdl].get(:get_list).include?(resource[:name])
  end
end
