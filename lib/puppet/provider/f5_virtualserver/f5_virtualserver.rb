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
    instances = []
    response = transport[wsdl].call(:get_list)
    if response.body[:get_list_response][:return][:item]
      # Force to array to account for only one virtualserver.
      Array(response.body[:get_list_response][:return][:item]).each do |name|
        instances << new(:name => name)
      end
    end
    instances
  end

  methods = [
    'cmp_enabled_state',
    'connection_mirror_state',
    'default_pool_name',
    'enabled_state',
    'fallback_persistence_profile',
    'last_hop_pool',
    'nat64_state',
    'protocol',
    'rate_class',
    'source_port_behavior',
    'translate_address_state',
    'translate_port_state',
    'type',
    'wildmask'
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      message = { virtual_servers: { item: resource[:name] }}
      response = transport[wsdl].call("get_#{method}".to_sym, message: message)
      response.body["get_#{method}_response".to_sym][:return][:item]
    end
    define_method("#{method}=") do |value|
      message = { virtual_servers: { item: resource[:name] }, types: { item: resource[method.to_sym]}}
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

  def enabled_state=(value)
    message = { virtual_servers: { item: resource[:name] }, states: { item: value }}
    transport[wsdl].call(:set_enabled_state, message: message)
  end

  def cmp_enabled_state=(value)
    message = { virtual_servers: { item: resource[:name] }, states: value}
    transport[wsdl].call(:set_cmp_enabled_state, message: message)
  end

  def connection_mirror_state=(value)
    message = { virtual_servers: { item: resource[:name] }, states: value}
    transport[wsdl].call(:set_connection_mirror_state, message: message)
  end

  def snat_pool
    message = { virtual_servers: { item: resource[:name] }}
    response = transport[wsdl].call(:get_snat_pool, message: message)
    response.body[:get_snat_pool_response][:return][:item]
  end

  def snat_pool=(value)
    message = { virtual_servers: { item: resource[:name] }, snatpools: {item: value}}
    transport[wsdl].call(:set_snat_pool, message: message)
  end

  def available_priority
    message = { virtual_servers: { item: resource[:name] }}
    @priority ||= transport[wsdl].call(:get_rule, message: message).body[:get_rule_response][:return][:item].collect do |item|
      if item.is_a?(Hash)
        if item.has_key?(:priority)
          item[:priority]
        end
      end
    end

    if @priority == [nil]
      @priority = [0]
    else
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
  end

  def clone_pool
    pool = {}
    message = { virtual_servers: { item: resource[:name] }}
    response = transport[wsdl].get(:get_clone_pool, message)
    if response
      response.each do |p|
        if p.is_a?(Hash)
          pool[p[:pool_name]] = p[:type]
        end
      end
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

    remove = { virtual_servers: { item: resource[:name] }, clone_pools: { item: [to_remove]}}
    add = { virtual_servers: { item: resource[:name] }, clone_pools: { item: [to_add]}}
    transport[wsdl].call(:remove_clone_pool, remove) unless to_remove.empty?
    transport[wsdl].call(:add_clone_pool, add) unless to_add.empty?
  end

  def persistence_profile
    profiles = {}
    message = { virtual_servers: { item: resource[:name] }}
    response = transport[wsdl].get(:get_persistence_profile, message)
    if response
      response.each do |p|
        if p.is_a?(Hash)
          profiles[p[:profile_name]] = p[:default_profile]
        end
      end
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

    remove = { virtual_servers: { item: resource[:name] }, clone_pools: { item: [to_remove]}}
    add = { virtual_servers: { item: resource[:name] }, clone_pools: { item: [to_add]}}
    transport[wsdl].call(:remove_persistence_profile, remove) unless to_remove.empty?
    transport[wsdl].call(:add_persistence_profile, add) unless to_add.empty?
  end

  def profile
    profiles = {}
    message = { virtual_servers: { item: resource[:name] }}
    response = transport[wsdl].call(:get_profile, message: message).body[:get_profile_response][:return][:item][:item]
    # This is ugly but we can get back a hash 
    Array(response).each do |hash|
      if hash.is_a?(Hash)
        profiles[hash[:profile_name]] = hash[:profile_context]
      end
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

    remove = { virtual_servers: { item: resource[:name] }, profiles: { item: [to_remove]}}
    add = { virtual_servers: { item: resource[:name] }, profiles: { item: [to_add]}}
    transport[wsdl].call(:remove_profile, message: remove) unless to_remove.empty?
    transport[wsdl].call(:add_profile, message: add) unless to_add.empty?
  end

  def rule
    # Because rule changes are not atomic, we are ignoring priority.
    message = { virtual_servers: { item: resource[:name] }}
    response = transport[wsdl].get(:get_rule, message)
    if response
      response.collect do |rule|
        rule[:rule_name]
      end
    end
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
    message = { virtual_servers: { item: resource[:name] }}
    response = transport[wsdl].call(:get_rule, message: message)
    # This is fairly torturous but we're getting back a hash of arrays that
    # then point to hashs and sometimes they don't contain hashes but actually
    # just the trail of the body.  I hate SOAP and I hate XML.
    response.body[:get_rule_response][:return][:item].each do |list|
      hash = list.last
      if hash.is_a?(Hash)
        rules[hash[:rule_name]] = hash[:priority]
      end
    end

    # Only add new rules and use first available priority.
    to_add = []
    (resource[:rule] - rules.keys).each do |r|
      to_add << {"rule_name" => r, "priority" => available_priority}
    end
    message = { virtual_servers: { item: resource[:name] }, rules: { item: [to_add]}}
    transport[wsdl].call(:add_rule, message: message) unless to_add.empty?

    to_remove = []
    (rules.keys - resource[:rule]).each do |r|
      to_remove << {"rule_name" => r, "priority" => rules[r]}
    end
    message = { virtual_servers: { item: resource[:name] }, rules: { item: [to_remove]}}
    transport[wsdl].call(:remove_rule, message: message) unless to_remove.empty?
  end

  def connection_limit
    message = { virtual_servers: { item: resource[:name] }}
    val = transport[wsdl].call(:get_connection_limit, message: message).body[:get_connection_limit_response][:return][:item]
    to_64s(val)
  end

  def connection_limit=(value)

    message = { virtual_servers: { item: resource[:name] }, limits: { item: to_32h(resource[:connection_limit])}}
    transport[wsdl].call(:set_connection_limit, message: message)
  end

  def gtm_score
    message = { virtual_servers: { item: resource[:name] }}
    val = transport[wsdl].call(:get_gtm_score, message: message).body[:get_gtm_score_response][:return][:item]
    to_64s(val)
  end

  def gtm_score=(value)
    message = { virtual_servers: { item: resource[:name] }, scores: { item: to_32h(resource[:gtm_score])}}
    transport[wsdl].call(:set_gtm_score, message: message)
  end

  def destination
    message = { virtual_servers: { item: resource[:name] }}
    destination = transport[wsdl].call(:get_destination, message: message).body[:get_destination_response][:return][:item]

    return "#{destination[:address]}:#{destination[:port]}"
  end

  def destination=(value)
    destination = { :address => network_address(resource[:destination]),
                    :port    => network_port(resource[:destination])}

    message = { virtual_servers: { item: resource[:name] }, destination: { item: [destination] }}
    transport[wsdl].call(:set_destination, message: message)
  end

  def snat_type
    message = { virtual_servers: { item: resource[:name] }}
    transport[wsdl].call(:get_snat_type, message: message).body[:get_snat_type_response][:return][:item]
  end

  def snat_type=(value)
    case resource[:snat_type]
    when 'SNAT_TYPE_AUTOMAP'
      message = { virtual_servers: { item: resource[:name] }}
      transport[wsdl].call(:set_snat_automap, message: message)
    when 'SNAT_TYPE_NONE'
      message = { virtual_servers: { item: resource[:name] }}
      transport[wsdl].call(:set_snat_none, message: message)
    when 'SNAT_TYPE_SNATPOOL'
      message = { virtual_servers: { item: resource[:name] }, snatpools: {item: resource[:snat_pool]}}
      transport[wsdl].call(:set_snat_pool, message: message)
    when 'SNAT_TYPE_TRANSLATION_ADDRESS'
      Puppet.warning("Puppet::Provider::F5_VirtualServer: currently F5 API does not appear to support a way to set SNAT_TYPE_TRANSLATION_ADDRESS.")
    end
  end

  def vlan
    message = { virtual_servers: { item: resource[:name] }}
    val = transport[wsdl].get(:get_vlan, message)
    if val
      hash = Hash.new
      hash['state'] = val[:state] if val[:state]
      if val[:vlans]
        hash['vlans'] = val[:vlans][:item] if val[:vlans][:item]
      else
        hash['vlans'] = []
      end
      hash
    else
      nil
    end
  end

  def vlan=(value)
    message = { virtual_servers: { item: resource[:name] }, vlans: { item: { state: resource[:vlan]['state'], vlans: { item: resource[:vlan]['vlans'] }}}}
    transport[wsdl].call(:set_vlan, message: message)
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VirtualServer: creating F5 virtual server #{resource[:name]}")

    vs_definition = { :name     => resource[:name],
                      :address  => network_address(resource[:destination]),
                      :port     => network_port(resource[:destination]),
                      :protocol => resource[:protocol] }
    vs_wildmask  = resource[:wildmask]
    vs_resources = { :type => resource[:type], :default_pool_name => resource[:default_pool_name] }
    vs_profiles  = []

    message = { definitions: { item: [vs_definition]}, wildmasks: { item: [vs_wildmask] }, resources: { item: [vs_resources] }, profiles: { item: [vs_profiles] }}
    transport[wsdl].call(:create, message: message)

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
    message = { virtual_servers: { item: resource[:name] }}
    transport[wsdl].call(:delete_virtual_server, message: message)
  end

  def exists?
    response = transport[wsdl].get(:get_list)
    if response
      response.include?(resource[:name])
    end
  end
end
