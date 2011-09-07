Puppet::Type.newtype(:f5_virtualserver) do
  @doc = "Manage F5 virtualserver."

  apply_to_device

  ensurable do
    desc "Add or delete virtualserver."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The virtual server name."
  end

  newproperty(:actual_hardware_acceleration) do
    desc "The virtual server actual hardware acceleration config."
    newvalues(/^HW_ACCELERATION_MODE_(NONE|ASSIST|FULL)$/)
  end

  newproperty(:cmp_enable_mode) do
    desc "The virtula server cmp enable mode."
    newvalues(/^RESOURCE_TYPE_CMP_ENABLE_(ALL|SINGLE|GROUP|UNKNOWN)$/)
  end

  newproperty(:cmp_enabled_state) do
    desc "The virtula server cmp enable state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:connection_limit) do
    desc "The virtula server connection limit."
    newvalues(/^\d+$/)
  end

  newproperty(:connection_mirror_state) do
    desc "The virtula server connection limit."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:default_pool_name) do
    desc "The virtual server default pool name."
  end

  newproperty(:destination) do
    desc "The virtual server destination virtual addrss adn port."
  end

  newproperty(:enabled_state) do
    desc "The virtual server state."
  end

  newproperty(:fallback_persistence_profile) do
    desc "The virtual server fallback persistent profile."
  end

  newproperty(:gtm_score) do
    desc "The virtual server gtm score."
  end

  newproperty(:last_hop_pool) do
    desc "The virtual server lasnat64 state."
  end

  newproperty(:nat64_state) do
    desc "The virtual server nat64 state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:protocol) do
    desc "The virtual server protocol."
    newvalues(/^PROTOCOL_(ANY|IPV6|ROUTING|NONE|FRAGMENT|DSTOPTS|TCP|UDP|ICMP|ICMPV6|OSPF|SCTP)$/)
  end

  newproperty(:rate_class) do
    desc "The virtual server rate class."
  end

  newproperty(:profile, :array_matching => :all) do
    desc "Adds/associates profiles to the specified virtual servers."
  end

  newproperty(:rule,  :array_matching => :all) do
    desc "Adds/associates rules to the specified virtual servers."
  end

  newproperty(:snat_pool) do
  end

  newproperty(:source_port_behavior) do
    desc "The virtual server source port behavior."
    newvalues(/^SOURCE_PORT_(PRESERVE|PRESERVE_STRICT|CHANGE)$/)
  end

  newproperty(:translate_address_state) do
    desc "The virtual server translate address state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:translate_port_state) do
    desc "The virtual server translate port state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:type) do
    desc "The virtual server type."
    newvalues(/^RESOURCE_TYPE_(POOL|IP_FORWARDING|L2_FORWARDING|REJECT|FAST_L4|FAST_HTTP|STATELESS)$/)
  end

  newproperty(:vlan) do
    desc "The virtual server vlan."
  end

  newproperty(:wildmask) do
    desc "The virtual server wildmask."
  end
end
