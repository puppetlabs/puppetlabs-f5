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

  methods = [ 'actual_hardware_acceleration',
    'cmp_enable_mode',
    'cmp_enabled_state',
    # 'connection_limit',
    'connection_mirror_state',
    'default_pool_name',
    'enabled_state',
    'fallback_persistence_profile',
    # 'gtm_score',
    'last_hop_pool',
    'nat64_state',
    'protocol',
    'rate_class',
    'snat_automap',
    'snat_none',
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
    profiles = transport[wsdl].get_profile(resource[:name]).first.map {|p| {"profile_name" => p.profile_name}}
    # We get TCP by default.  Trying to create it will cause problems.
    return profiles - [{"profile_name"=>"tcp"}]
  end

  def profile=(profiles)
    # TODO: For the same reason as with rules, this is far from production
    # ready.

    Puppet.debug("Puppet::Provider::F5_VirtualServer: Deleting all current profiles for #{resource[:name]}")
    transport[wsdl].remove_all_rules(resource[:name])
    transport[wsdl].remove_all_profiles(resource[:name])

    # Now create the array of hashes that iControl expects
    new_profiles = profiles.map do |p|
      # We're hard-coding the profile_context because that's the only one I've
      # seen used
      {:profile_name => p["profile_name"], :profile_context => "PROFILE_CONTEXT_TYPE_ALL"}
    end

    transport[wsdl].add_profile(resource[:name], [new_profiles])
  end

  def connection_limit
    val = transport[wsdl].get_connection_limit(resource[:name]).first
    [val.high, val.low]
  end

  def connection_limit=(value)
    transport[wsdl].set_connection_limit(resource[:name], resource[:connection_limit])
  end

  def gtm_score
    val = transport[wsdl].get_gtm_score(resource[:name]).first
    [val.high, val.low]
  end

  def gtm_score=(value)
    transport[wsdl].set_gtm_score(resource[:name], resource[:gtm_score])
  end

  def destination
    destination = transport[wsdl].get_destination(resource[:name])

    destination = destination.collect { |system|
      "#{system.address}:#{system.port}"
    }.sort.join(',')
  end

  def destination=
    transport[wsdl].set_destination(resource[:name],
      [[{:address => fetch_address(resource[:destination]),
         :port    => fetch_port(resource[:destination])}]])
  end

  def fetch_address(dest)
    dest.split(':')[0]
  end

  def fetch_port(dest)
    dest.split(':')[1]
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VirtualServer: creating F5 virtual server #{resource[:name]}")

    vs_definition = [{"name" => resource[:name],
                      "address" => fetch_address(resource[:destination]),
                      "port" => fetch_port(resource[:destination]).to_i,
                      "protocol" => resource[:protocol]}]
    vs_wildmask = resource[:wildmask]
    vs_resources = [{"type" => resource[:type]}]
    vs_profiles = [[]]

    transport[wsdl].create(vs_definition, vs_wildmask, vs_resources, vs_profiles)

    if resource[:default_pool_name]
      self.default_pool_name = resource[:default_pool_name]
    end

    if resource[:profile]
      self.profile = resource[:profile]
    end

    if resource[:rule]
      self.rule = resource[:rule]
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
