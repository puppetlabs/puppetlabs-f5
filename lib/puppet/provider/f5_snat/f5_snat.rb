require 'puppet/provider/f5'

Puppet::Type.type(:f5_snat).provide(:f5_snat, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snat"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.SNAT'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    Array(transport[wsdl].get(:get_list)).collect do |name|
      new(:name => name)
    end
  end

  {
    'connection_mirror_state' => 'states',
    'description'             => 'descriptions',
    'source_port_behavior'    => 'source_port_behaviors',
    'vlan'                    => 'vlans',
  }.each do |method, type|
    define_method(method.to_sym) do
      transport[wsdl].get("get_#{method}".to_sym, { snats: { item: resource[:name] }})
    end
    define_method("#{method}=") do |value|
      message = { snats: { item: resource[:name] }, type => resource[method.to_sym]}
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

  def original_address
    val = transport[wsdl].get(:get_original_address, { snats: { item: resource[:name] }})
    Array(val)
  end

  def translation_target
    val = transport[wsdl].get(:get_translation_target, { snats: { item: resource[:name] }})
    { type: val[:type], translation_object: val[:translation_object] }
  end

  def translation_target=(value)
    message = { snats: { items: resource[:name] }, targets: { items: { type: value[:type], translation_object: value[:translation_target] }}}
    transport[wsdl].call(:set_translation_target, message: message)
  end

  def vlan
    val = transport[wsdl].get(:get_vlan, { snats: { item: resource[:name] }})
    result = { 'state' => val[:state] }
    # Skip if we don't have a state in the return.
    if val[:vlans][:state]
      result['vlans'] = val[:vlans]
    end
    result
  end

  def vlan=(value)
    message = { snats: { items: resource[:name] }, vlans: { items: resource[:vlan] }}
    transport[wsdl].call(:set_vlan, message: message)
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Snat: creating F5 snat #{resource[:name]}")
    resource[:original_address] ||= ['0.0.0.0', '0.0.0.0']
    resource[:vlan] ||= ['STATE_DISABLED', '']

    message = {
      snats: {
        items: {
          name: resource[:name], target: resource[:translation_target]
        }
      },
      original_addresses: {
        items: {
          items: resource[:original_address]
        },
      },
      vlans: {
        items: {
          # Elements in the subhash are strings, not symbols.
          state: resource[:vlan]['state'],
          vlans: resource[:vlan]['vlans'],
        }
      }
    }

    transport[wsdl].call(:create, message: message)
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Snat: destroying F5 snat #{resource[:name]}")
    transport[wsdl].call(:delete_snat, messages: { snats: { item: resource[:name] }})
  end

  def exists?
    transport[wsdl].get(:get_list).include?(resource[:name])
  end
end
