require 'puppet/provider/f5'

Puppet::Type.type(:f5_virtualserver).provide(:f5_virtualserver, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 device"

  confine :feature => :posix
  defaultfor :feature => :posix

  @priority = []

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

  def available_priority
    @priority ||= transport[wsdl].get_rule(resource[:name]).first.collect {|p| p.priority}

    list = @priority.sort
    list.each_with_index do |val, i|
      if val > i
        @priority << i
        return i
      end
    end
    @priority << list.size
    return list.size
  end

  def clone_pool
    pool = {}
    transport[wsdl].get_clone_pool(resource[:name]).first.each do |p|
      pool[p.pool_name] = p.type
    end
    pool
  end

  def clone_pool=(value)
    existing  = clone_pool
    new       = resource[:clone_pool]
    to_remove = []
    to_add    = []

    (existing.keys - new.keys).each do |p|
      to_remove << {'pool_name'=> p, 'type'=> existing[p]}
    end

    new.each do |k, v|
      if ! existing.has_key?(k) then
        to_add << {'pool_name'=> k, 'type'=> v.to_s}
      elsif v != existing[k]
        to_remove << {'pool_name'=> k, 'type'=> existing[k]}
        to_add << {'pool_name' => k, 'type'=> v.to_s}
      end
    end

    transport[wsdl].remove_clone_pool(resource[:name], [to_remove]) unless to_remove.empty?
    transport[wsdl].add_clone_pool(resource[:name], [to_add]) unless to_add.empty?
  end

  def persistence_profile
    profiles = {}
    transport[wsdl].get_persistence_profile(resource[:name]).first.each do |p|
      profiles[p.profile_name] = p.default_profile
    end
    profiles
  end

  def persistence_profile=(value)
    existing  = persistence_profile
    new       = resource[:persistence_profile]
    to_remove = []
    to_add    = []

    # The retrieved value is boolean, but we cannot set the value via boolean. So all deafult_profile value is converted to_s
    # transport[wsdl].add_persistence_profile(resource[:name], [[{"default_profile"=>false, "profile_name"=>"my_cookie"}]])
    # SOAP::FaultError: Cannot convert null value to a boolean.
    #   from
    (existing.keys - new.keys).each do |p|
      to_remove << {'profile_name'=> p, 'default_profile'=> existing[p].to_s}
    end

    # We don't have a modify API, so remove and re-add profile.
    new.each do |k, v|
      if ! existing.has_key?(k) then
        to_add << {'profile_name'=> k, 'default_profile'=> v.to_s}
      elsif v != existing[k]
        to_remove << {'profile_name'=> k, 'default_profile'=> existing[k].to_s}
        to_add << {'profile_name' => k, 'default_profile'=> v.to_s}
      end
    end

    transport[wsdl].remove_persistence_profile(resource[:name], [to_remove]) unless to_remove.empty?
    transport[wsdl].add_persistence_profile(resource[:name], [to_add]) unless to_add.empty?
  end

  def profile
    profiles = {}
    transport[wsdl].get_profile(resource[:name]).first.each do |p|
      # For now suppress the default tcp profile. (see profile= comment)
      profiles[p.profile_name] = p.profile_context #unless p.profile_name == 'tcp'
    end
    profiles
  end

  def profile=(value)
    existing  = self.profile
    new       = resource[:profile]
    to_remove = []
    to_add    = []

    (existing.keys - new.keys).each do |p|
      to_remove << {'profile_name'=> p, 'profile_context'=> existing[p]}
    end

    new.each do |k, v|
      if ! existing.has_key?(k) then
        to_add << {'profile_name'=> k, 'profile_context'=> v} unless k=='tcp'
      elsif v != existing[k]
        to_remove << {'profile_name'=> k, 'profile_context'=> existing[k]}
        to_add << {'profile_name' => k, 'profile_context'=> v} unless k=='tcp'
      end
    end

    transport[wsdl].remove_profile(resource[:name], [to_remove]) unless to_remove.empty?
    transport[wsdl].add_profile(resource[:name], [to_add]) unless to_add.empty?
  end

  def rule
    # Because rule changes are not atomic, we are ignoring priority.
    transport[wsdl].get_rule(resource[:name]).first.collect {|r| r.rule_name}
  end

  def rule=(value)
    # Unfortunately iControl doesn't support modifying existing rule
    # priorities.  This means if we had a our rules set to {"ruleA" => 0, "ruleB"
    # => 1} and we wanted to swap the priorities we have to remove all rules then
    # add our new ones with a second call.  This is _really_ bad because it means
    # that there will be an brief outage while the rules are removed.
    #
    # The current approach is to handle priorities from inside the rules:
    # http://devcentral.f5.com/wiki/iRules.priority.ashx
    #
    # That document shows priorities can be bound to events.

    rules = {}
    transport[wsdl].get_rule(resource[:name]).first.each do |r|
      rules[r.rule_name] = r.priority
    end

    # Only add new rules and use first available priority.
    to_add = []
    (resource[:rule] - rules.keys).each do |r|
      to_add << {"rule_name" => r, "priority" => available_priority}
    end
    transport[wsdl].add_rule(resource[:name], [to_add]) unless to_add.empty?

    to_remove = []
    (rules.keys - resource[:rule]).each do |r|
      to_remove << {"rule_name" => r, "priority" => rules[r]}
    end
    transport[wsdl].remove_rule(resource[:name], [to_remove]) unless to_remove.empty?
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
    
    resource[:profile].each do |k, v|
      vs_profiles << { :profile_name    => k,
                       :profile_context => v }
    end

    transport[wsdl].create([vs_definition], vs_wildmask, [vs_resources], [vs_profiles])

    # profile should be the first value added since some other settings require it.
    methods = [ 'profile',
                'clone_pool',
                'cmp_enabled_state',
                'connection_mirror_state',
                'default_pool_name',
                'enabled_state',
                'fallback_persistence_profile',
                'last_hop_pool',
                'nat64_state',
                'persistence_profile',
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
