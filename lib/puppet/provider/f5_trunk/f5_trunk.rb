require 'puppet/provider/f5'

Puppet::Type.type(:f5_trunk).provide(:f5_trunk, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 trunk"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.Trunk'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [
    'active_lacp_state',
    'distribution_hash_option',
    'lacp_enabled_state',
    'lacp_timeout_option',
    'link_selection_policy',
    'stp_enabled_state',
    'stp_protocol_detection_reset_state',
  ]

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

  def interface
    @interfaces=transport[wsdl].get_interface(resource[:name]).first
  end
  def interface=(value)
    transport[wsdl].remove_interface([resource[:name]], [@interfaces - value])
    transport[wsdl].add_interface([resource[:name]], [value - @interfaces])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_trunk: creating F5 trunk #{resource[:name]}")
    #iControl is inconsistant so that whe have to set up lacp_states later
    transport[wsdl].create(resource[:name], [0], [resource[:interface]])
    
    methods = [
      'active_lacp_state',
      'distribution_hash_option',
      'lacp_enabled_state',
      'lacp_timeout_option',
      'link_selection_policy',
      'stp_enabled_state',
      'stp_protocol_detection_reset_state',
    ]
     
    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Pool: destroying F5 trunk #{resource[:name]}")
    transport[wsdl].delete_trunk(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
