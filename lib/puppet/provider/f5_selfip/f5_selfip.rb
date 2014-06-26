require 'puppet/provider/f5'

Puppet::Type.type(:f5_selfip).provide(:f5_selfip, :parent => Puppet::Provider::F5) do
  @doc = 'Manage F5 self IPs.'

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.SelfIPV2'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    instances = []
    get_list.each do |selfip|
      instances << new(name: selfip, ensure: :present)
    end
    instances
  end

  def self.prefetch(resources)
    selfips = instances
    resources.keys.each do |name|
      if provider = selfips.find { |selfip| selfip.name == name }
        resources[name].provider = provider

      end
    end
  end

  def destroy
    message = { routes: { item: resource[:name] }}
    transport[wsdl].call(:delete_self_ip, message: message)

    @property_hash[:ensure] = :absent
  end

  def create
    message = {
      self_ips:         { item: resource[:name] },
      vlan_names:       { item: resource[:vlan] },
      addresses:        { item: resource[:address] },
      netmasks:         { item: resource[:netmask] },
      traffic_groups:   { item: resource[:traffic_group] },
      floating_states:  { item: resource[:floating_state] }
    }
    transport[wsdl].call(:create, message: message)
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def address
    message = { self_ips: { item: self.name } }
    transport[wsdl].get(:get_address, message)
  end

  # Unfortunately you can't change the address.
  def address=(value)
    Puppet.debug('Cannot change this value, destroying and recreating.')
    destroy
    create
  end

  def floating_state
    message = { self_ips: { item: self.name } }
    transport[wsdl].get(:get_floating_state, message)
  end

  def floating_state=(value)
    message = {
      self_ips:  { item: self.name },
      states:    { item: resource[:floating_state] },
    }
    transport[wsdl].call(:set_floating_states, message: message)
  end

  def netmask
    message = { self_ips: { item: self.name }}
    transport[wsdl].get(:get_netmask, message)
  end

  # Unfortunately you can't change the netmask either.
  def netmask=(value)
    Puppet.debug('Cannot change this value, destroying and recreating.')
    destroy
    create
  end

  def traffic_group
    message = { self_ips: { item: self.name }}
    transport[wsdl].get(:get_traffic_group, message)
  end

  def traffic_group=(value)
    message = {
      self_ips:       { item: self.name },
      traffic_groups: { item: resource[:traffic_group] },
    }
    transport[wsdl].call(:set_traffic_group, message: message)
  end

  def vlan
    message = { self_ips: { item: self.name }}
    transport[wsdl].get(:get_vlan, message)
  end

  def vlan=(value)
    message = {
      self_ips:   { item: self.name },
      vlan_names: { item: resource[:vlan] },
    }
    transport[wsdl].call(:set_vlan, message: message)
  end

  # Obtain a list of static routes.
  def self.get_list
    response = transport[wsdl].get(:get_list)
    return Array(response)
  end
end
