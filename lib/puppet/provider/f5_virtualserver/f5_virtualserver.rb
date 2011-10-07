require 'puppet/provider/f5'

Puppet::Type.type(:f5_virtualserver).provide(:f5_virtualserver, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 device"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.VirtualServer'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'cmp_enabled_state',
    'connection_mirror_state',
    'default_pool_name',
    'enabled_state',
    'fallback_persistence_profile',
    'last_hop_pool',
    'nat64_state',
    'protocol',
    'rate_class',
    'snat_pool',
    'source_port_behavior',
    'translate_address_state',
    'translate_port_state',
    'type',
    'wildmask']

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

  def rule
    transport[wsdl].get_rule(resource[:name]).first.map {|r| {"rule_name" => r.rule_name, "priority" => r.priority.to_s}}
  end

  def rule=(rules)
    # TODO
    #
    # Unfortunately iControl doesn't support modifying existing rule
    # priorities.  This means if we had a our rules set to {"ruleA" => 0, "ruleB"
    # => 1} and we wanted to swap the priorities we have to remove all rules then
    # add our new ones with a second call.  This is _really_ bad because it means
    # that there will be an brief outage while the rules are removed.
    #
    # What we will likely have to do is create dup the current rules into
    # temporary names, remove the old ones, then add the correct ones and delete
    # the dups. Yay.
    Puppet.debug("Puppet::Provider::F5_VirtualServer: Deleting all current rules for #{resource[:name]}")
    transport[wsdl].remove_all_rules(resource[:name])
    transport[wsdl].add_rule(resource[:name], [rules])
  end

  def profile
    profiles = {}
    transport[wsdl].get_profile(resource[:name]).first.each do |p|
      # For now suppress the default tcp profile.
      profiles[p.profile_name] = p.profile_context unless p.profile_name == 'tcp'
    end
    profiles
  end

  def profile=(profiles)
    existing  = self.profile
    new       = resource[:profile]
    to_remove = []
    to_add    = []

    (existing.keys - new.keys).each do |p|
      to_remove << {'profile_name'=> p, 'profile_context'=> existing[p]}
    end

    puts new.class
    new.each do |k, v|
      if ! existing.has_key?(k) then
        to_add << {'profile_name'=> k, 'profile_context'=> v}
      elsif v != existing[k]
        to_remove << {'profile_name'=> k, 'profile_context'=> existing[k]}
        to_add << {'profile_name' => k, 'profile_context'=> v}
      end
    end

    # F5 API is rather confusing, it supports four different profile methods:
    # add_authentication_profile
    # add_httpclass_profile
    # add_persistence_profile
    # add_profile
    # After testing it isn't clear which should be invoked, so this does not cover all profile configuration:
    transport[wsdl].remove_profile(resource[:name], [to_remove]) unless to_remove.empty?
    transport[wsdl].add_profile(resource[:name], [to_add]) unless to_add.empty?
  end

  def connection_limit
    val = transport[wsdl].get_connection_limit(resource[:name]).first
    to_64s(val)
  end

  def connection_limit=(value)
    transport[wsdl].set_connection_limit(resource[:name], [ to_32h(resource[:connection_limit]) ] )
  end

  def gtm_score
    val = transport[wsdl].get_gtm_score(resource[:name]).first
    to_64s(val)
  end

  def gtm_score=(value)
    transport[wsdl].set_gtm_score(resource[:name], [ to_32h(resource[:gtm_score]) ] )
  end

  def destination
    destination = transport[wsdl].get_destination(resource[:name])

    destination = destination.collect { |system|
      "#{system.address}:#{system.port}"
    }.sort.join(',')
  end

  def destination=(value)
    destination = { :address => network_address(resource[:destination]),
                    :port    => network_port(resource[:destination])}

    transport[wsdl].set_destination(resource[:name], [ destination ])
  end

  def snat_type
    transport[wsdl].get_snat_type(resource[:name]).first
  end

  def snat_type=(value)
    case resource[:snat_type]
    when 'SNAT_TYPE_AUTOMAP'
      transport[wsdl].set_snat_automap(resource[:name])
    when 'SNAT_TYPE_NONE'
      transport[wsdl].set_snat_none(resource[:name])
    when 'SNAT_TYPE_SNATPOOL'
      transport[wsdl].set_snat_pool(resource[:name], resource[:snat_pool])
    when 'SNAT_TYPE_TRANSLATION_ADDRESS'
      Puppet.warning("Puppet::Provider::F5_VirtualServer: currently F5 API does not appear to support a way to set SNAT_TYPE_TRANSLATION_ADDRESS.")
    end
  end

  def vlan
    val = transport[wsdl].get_vlan(resource[:name]).first
    { 'state' => val.state, 'vlans' => val.vlans }
  end

  def vlan=(value)
    transport[wsdl].set_vlan(resource[:name], [resource[:vlan]])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VirtualServer: creating F5 virtual server #{resource[:name]}")

    vs_definition = { :name     => resource[:name],
                      :address  => network_address(resource[:destination]),
                      :port     => network_port(resource[:destination]),
                      :protocol => resource[:protocol] }
    vs_wildmask  = resource[:wildmask]
    vs_resources = { :type => resource[:type] }
    vs_profiles  = []

    transport[wsdl].create([vs_definition], vs_wildmask, [vs_resources], [vs_profiles])

    methods = [ 'cmp_enabled_state',
                'connection_mirror_state',
                'default_pool_name',
                'enabled_state',
                'fallback_persistence_profile',
                'last_hop_pool',
                'nat64_state',
                'profile',
                'rate_class',
                'rule',
                'snat_pool',
                'snat_type',
                'source_port_behavior',
                'translate_address_state',
                'translate_port_state',
                'type',
                'vlan' ]

    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying F5 virtual server #{resource[:name]}")
    transport[wsdl].delete_virtual_server(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
