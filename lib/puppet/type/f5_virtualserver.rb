Puppet::Type.newtype(:f5_virtualserver) do

  @doc = "Manage F5 virtualserver."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The virtual server name."
  end

  newproperty(:clone_pool) do
    desc "The virtual server clone pool."

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:cmp_enabled_state) do
    desc "The virtual server cmp enable state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:connection_limit) do
    desc "The virtual server connection limit."
    newvalues(/^\d+$/)
  end

  newproperty(:connection_mirror_state) do
    desc "The virtual server connection limit."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:default_pool_name) do
    desc "The virtual server default pool name."
  end

  newproperty(:destination) do
    desc "The virtual server destination virtual address and port."
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

  newproperty(:persistence_profile) do
    desc "the virtual server persistence profiles."

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:profile) do
    desc "the virtual server profiles."

    # this is what f5 appears to reset the device, it's not something we can configure:
    #defaultto({ "tcp" => "profile_context_type_all" })

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:rule, :array_matching => :all) do
    desc "The virtual server rules. The rule order isn't enforced since F5 API does not provide ability to reorder rules, use irule priority to dictate rule processing order"

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:snat_type) do
    desc "The virtual server snat type."
    newvalues(/^SNAT_TYPE_(NONE|TRANSLATION_ADDRESS|SNATPOOL|AUTOMAP)$/)
  end

  newproperty(:snat_pool) do
    desc "Virtual server snat_pool."
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

    munge do |value|
      raise Puppet::Error, "Puppet::Type::F5_VirtualServer: vlan must be a hash." unless value.is_a? Hash

      unless value.empty?
        value.keys.each do |k|
          raise Puppet::Error, "Puppet::Type::F5_VirtualServer: vlan does not support key #{k}" unless k =~ /^(state|vlans)$/

          # ensure vlans value is an array
          value[k] = Array(value[k]) if k == 'vlans'
        end

        raise Puppet::Error, "Puppet::Type::F5_VirtualServer: vlan missing key." unless value.size == 2
      end

      value
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:wildmask) do
    desc "The virtual server wildmask."
  end
end
