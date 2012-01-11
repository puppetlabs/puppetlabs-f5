require 'puppet/provider/f5'

Puppet::Type.type(:f5_vlan).provide(:f5_vlan, :parent => Puppet::Provider::F5) do
  @doc = "Manages F5 VLAN"

  confine    :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.VLAN'
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
    'failsafe_action',
    'failsafe_state',
    'failsafe_timeout',
    'learning_mode',
    'mac_masquerade_address',
    'mtu',
    'source_check_state',
    'vlan_id',
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

  def member
    members = transport[wsdl].get_member(resource[:name]).first
    members.collect { |vlan_member|
      {
        'member_name' => vlan_member.member_name,
        'member_type' => vlan_member.member_type,
        'tag_state'   => vlan_member.tag_state,
      }
    }
  end
  def member=(value)
    members          = resource[:member]
    current_members  = transport[wsdl].get_member(resource[:name]).first.collect do |vlan_member|
      {
        'member_name' => vlan_member.member_name,
        'member_type' => vlan_member.member_type,
        'tag_state'   => vlan_member.tag_state,
      }
    end
    transport[wsdl].remove_member([resource[:name]], [current_members - members])
    transport[wsdl].add_member([resource[:name]], [members - current_members])
  end

  def static_forwarding
    entries=transport[wsdl].get_static_forwarding(resource[:name]).first
    entries.collect {|entry|
      {
        'mac_address'    => entry.mac_address,
        'interface_name' => entry.interface_name,
        'interface_type' => entry.interface_type,
      } 
    }
  end
  def static_forwarding=(value)
    entries         = resource[:static_forwarding]
    current_entries = transport[wsdl].get_static_forwarding(resource[:name]).first.collect { |entry|
      {
        'mac_address'    => entry.mac_address,
        'interface_name' => entry.interface_name,
        'interface_type' => entry.interface_type
      }
    }
    transport[wsdl].remove_static_forwarding([resource[:name]], [current_entries - entries])
    transport[wsdl].add_static_forwarding([resource[:name]], [entries - current_entries])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VLAN: creating F5 VLAN #{resource[:name]}")
    members=[]
    resource[:member].keys.each do |member_name|
      members.push({:member_name => member_name, :member_type => resource[:member][member_name]['member_type'], :tag_state => resource[:member][member_name]['tag_state'] })
    end
    transport[wsdl].create([resource[:name]],[resource[:vlan_id]],[members],[resource[:failsafe_state]],[resource[:failsafe_timeout]],[resource[:mac_masquerade_address]])
    
    ## The create method provided by the iControl API does not set the following so that we have to do it here
    methods = [
      'failsafe_action',
      'source_check_state',
      'mtu',
    ]
    methods.each do |method|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", resource[:name], resource[method.to_sym])
      end
    end
    if resource[:static_forwarding].is_a?(Hash)
      transport[wsdl].add_static_forwarding([resource[:name]], [resource[:static_forwarding].keys.collect { |mac_address| { :mac_address => mac_address, :interface_name => resource[:static_forwarding][mac_address]['interface_name'], :interface_type => resource[:static_forwarding][mac_address]['interface_type'] } } ])
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VLAN: destroying F5 VLAN #{resource[:name]}")
    transport[wsdl].remove_all_static_forwardings(resource[:name])
    transport[wsdl].delete_vlan(resource[:name])
  end

  def exists?
    r=transport[wsdl].get_list.include?(resource[:name])
    Puppet.debug("Puppet::Provider::F5_VLAN: does F5 VLAN #{resource[:name]} exist ? #{r}")
    r
  end
  
end
