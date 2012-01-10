require 'puppet/provider/f5'

Puppet::Type.type(:f5_selfip).provide(:f5_selfip, :parent => Puppet::Provider::F5) do
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
    'description',
    'failsafe_action',
    'failsafe_state',
    'failsafe_timeout',
    'learning_mode',
    'mac_masquerade_address',
    'mtu',
    'source_check_state',
    'vlan_id'
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        Puppet.debug("Puppet::Provider::F5_VLAN: retrieving #{method} for #{resource[:name]}")
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
    result = {}
    members = transport[wsdl].get_member(resource[:name]).first
    members.each do |vlan_member|
      result[vlan_member.member_name] = {
        :member_type => vlan_member.member_type,
        :tag_state   => vlan_member.tag_state,
      }
    end
    result
  end

  def member=(value)
    current_members = transport[wsdl].get_member(resource[:name]).first
    current_members = current_members.collect { |vlan_member|
      vlan_member.member_name
    }

    members = resource[:member].keys

    # Should add new members first to avoid removing all members of the pool.
    (members - current_members).each do |vlan_member|
      Puppet.debug "Puppet::Provider::F5_VLAN: adding member #{vlan_member}"
      transport[wsdl].add_member([resource[:name]], [{:member_name => vlan_member.member_name, :member_type => value[vlan_member.member_name]['member_type'], :tag_state => value[vlan_member.member_name]['tag_state'] }])
    end

    (current_members - members).each do |vlan_member|
      Puppet.debug "Puppet::Provider::F5_Pool: removing member #{vlan_member}"
      transport[wsdl].remove_member([resource[:name]], [{:member_name => vlan_member.member_name, :member_type => value[vlan_member.member_name]['member_type'], :tag_state => value[vlan_member.member_name]['tag_state'] }])
    end

   
  end

  
  def create
    Puppet.debug("Puppet::Provider::F5_VLAN: creating F5 VLAN #{resource[:name]}")
    members=[]
    
    transport[wsdl].create([resource[:name]],[resource[:vlan_id]],[members],[resource[:failsafe_state]],[resource[:failsafe_timeout]],[resource[:mac_masquerade_address]])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VLAN: destroying F5 VLAN #{resource[:name]}")
    transport[wsdl].delete_vlan(resource[:name])
  end

  def exists?
    r=transport[wsdl].get_list.include?(resource[:name])
    Puppet.debug("Puppet::Provider::F5_VLAN: does F5 VLAN #{resource[:name]} exist ? #{r}")
    r
  end
end
