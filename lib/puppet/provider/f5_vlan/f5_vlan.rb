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

  def vlan_members
    @vlan_members ||= transport[wsdl].get_member(resource[:name]).first
  end

  def member
    vlan_members.collect! { |vlan_member|
      {
        'member_name' => vlan_member.member_name,
        'member_type' => vlan_member.member_type,
        'tag_state'   => vlan_member.tag_state,
      }
    }
  end

  def member=(value)
    transport[wsdl].remove_member([resource[:name]], [vlan_members - value])
    transport[wsdl].add_member([resource[:name]], [value - vlan_members])
  end

  def static_forwarding_table
    @static_forwarding_table ||= transport[wsdl].get_static_forwarding(resource[:name]).first
  end

  def static_forwarding
    static_forwarding_table.collect! {|entry|
      {
        'mac_address'    => entry.mac_address,
        'interface_name' => entry.interface_name,
        'interface_type' => entry.interface_type,
      }
    }
  end

  def static_forwarding=(value)
    transport[wsdl].remove_static_forwarding([resource[:name]], [static_forwarding_table - value])
    transport[wsdl].add_static_forwarding([resource[:name]], [value - static_forwarding_table])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VLAN: creating F5 VLAN #{resource[:name]}")

    bigip_version = /([\d\.]+)$/.match(facts["version"])
    if Gem::Version.new(bigip_version) < Gem::Version.new('11.0.0')
      transport[wsdl].create( [resource[:name]],
                              [resource[:vlan_id]],
                              [resource[:member]],
                              [resource[:failsafe_state]],
                              [resource[:failsafe_timeout]],
                              [resource[:mac_masquerade_address]] )
    else
      transport[wsdl].create_v2( [resource[:name]],
                                 [resource[:vlan_id]],
                                 [resource[:member]],
                                 [resource[:failsafe_state]],
                                 [resource[:failsafe_timeout]],
                                 [resource[:mac_masquerade_address]] )
    end

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
      transport[wsdl].add_static_forwarding( [resource[:name]],
        [ resource[:static_forwarding].keys.collect { |mac_address|
          { :mac_address    => mac_address,
            :interface_name => resource[:static_forwarding][mac_address]['interface_name'],
            :interface_type => resource[:static_forwarding][mac_address]['interface_type']
          }
        }] )
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
