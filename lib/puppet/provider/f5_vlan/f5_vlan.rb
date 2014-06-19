require 'puppet/provider/f5'

Puppet::Type.type(:f5_vlan).provide(:f5_vlan, :parent => Puppet::Provider::F5) do
  @doc = 'Manage F5 VLANs.'

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.VLAN'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    instances = []
    get_list.each do |vlan|
      instances << new(name: vlan, ensure: :present)
    end
    instances
  end

  def self.prefetch(resources)
    vlans = instances
    resources.keys.each do |name|
      if provider = vlans.find { |vlan| vlan.name == name }
        resources[name].provider = provider

      end
    end
  end

  def destroy
    message = { vlans: { item: resource[:name] }}
    transport[wsdl].call(:delete_vlan, message: message)

    @property_hash[:ensure] = :absent
  end

  def create
    members = Array.new(1) { Array.new(resource[:members].length) }
    members[0] = resource[:members]
    message = {
      vlans:           { item: resource[:name] },
      vlan_ids:        { item: resource[:vlan_id] },
      members:         { item: members },
      failsafe_states: { item: resource[:failsafe_state] },
      timeouts:        { item: resource[:timeout] },
    }
    transport[wsdl].call(:create_v2, message: message)
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def failsafe_state
    message = { vlans: { item: self.name } }
    transport[wsdl].get(:get_failsafe_state, message)
  end

  def failsafe_state=(value)
    message = {
      vlans:  { item: self.name },
      states: { item: resource[:failsafe_state] },
    }
    transport[wsdl].call(:set_failsafe_state, message: message)
  end

  def members
    message = { vlans: { item: self.name }}
    response = transport[wsdl].get(:get_member, message)
    return response.is_a?(Array) ? response : Array.new(1) { response }
  end

  # Unfortunately you can't change the members.
  def members=(value)
    Puppet.debug('Cannot change this value, destroying and recreating.')
    destroy
    create
  end

  def timeout
    message = { vlans: { item: self.name } }
    transport[wsdl].get(:get_failsafe_timeout, message)
  end

  def timeout=(value)
    message = {
      vlans:    { item: self.name },
      timeouts: { item: resource[:timeouts] },
    }
    transport[wsdl].call(:set_failsafe_timeout, message: message)
  end

  def vlan_id
    message = { vlans: { item: self.name }}
    transport[wsdl].get(:get_vlan_id, message)
  end

  def vlan_id=(value)
    message = {
      vlans:    { item: self.name },
      vlan_ids: { item: resource[:vlan_id] },
    }
    transport[wsdl].call(:set_vlan_id, message: message)
  end

  # Obtain a list of static routes.
  def self.get_list
    response = transport[wsdl].get(:get_list)
    return Array(response)
  end
end
