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
    'vlan',
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
    rules = transport[wsdl].get_rule(resource[:name]).first.map {|r| r.rule_name}

    # the 'munge' method in the type does not operate on arrays.  We want
    # 'rule => ["foo", "bar"]' to be equivalent to 'rule => ["bar", "foo"]'.
    if rules == resource[:rule].sort
      return resource[:rule]
    else
      return rules
    end
  end

  def rule=(rule_names)
    # Unfortunately iControl doesn't support modifying existing rule
    # priorities.  This means if we had a our rules set to {"ruleA" => 0, "ruleB"
    # => 1} and we wanted to swap the priorities we have to remove all rules then
    # add our new ones with a second call.  This is _really_ bad because it means
    # that there will be an brief outage while the rules are removed.
    #
    # The current approach is to handle priorities from inside the rules:
    # http://devcentral.f5.com/wiki/iRules.priority.ashx
    #
    # That document shows priorities can be bound to events.  For the priority
    # given to the rule in the virtual server we are simply going to use the
    # array index.

    # We can't call 'add_rule' for rules that already exist so we subtract the
    # known rules.
    to_add = []
    (rule_names - rule).each_with_index do |r, p|
      # priorities must be unique so we must account for the rules we exclude
      to_add << {"rule_name" => r, "priority" => rule.size + p}
    end
    transport[wsdl].add_rule(resource[:name], [to_add]) unless to_add.empty?

    to_remove = []
    (rule - rule_names).each_with_index do |r, p|
      to_remove << {"rule_name" => r, "priority" => p}
    end
    transport[wsdl].remove_rule(resource[:name], [to_remove]) unless to_remove.empty?
  end

  def profile
    profiles = transport[wsdl].get_profile(resource[:name]).first.map {|p| p.profile_name}

    # We get TCP by default.  Trying to create it will cause problems.
    profiles -= ["tcp"]

    # the 'munge' method in the type does not operate on arrays.  We want
    # 'profile => ["foo", "bar"]' to be equivalent to 'profile => ["bar",
    # "foo"]'.
    if profiles == resource[:profile].sort
      return resource[:profile]
    else
      return profiles
    end
  end

  def profile=(profiles)
    # We're hard-coding the profile_context because that's the only one I've
    # seen used
    to_add = (profiles - self.profile).map do |p|
      {"profile_name" => p, "profile_context" => "PROFILE_CONTEXT_TYPE_ALL"}
    end

    to_remove = (self.profile - profiles).map do |p|
      {"profile_name" => p, "profile_context" => "PROFILE_CONTEXT_TYPE_ALL"}
    end

    # We can't call 'add_profile' on a profile that already exists.  We need
    # to remove the already present profiles from the list provided to puppet.
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
