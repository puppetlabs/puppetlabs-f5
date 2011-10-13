Puppet::Type.newtype(:f5_snat) do
  @doc = "Manage F5 snat."

  apply_to_device

  ensurable do
    desc "Add or delete snat."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The snat name."
  end

  newproperty(:connection_mirror_state) do
    desc "The snat connection mirror state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:original_address) do
    desc "The snat original address/netmask."
    #TODO validate network address and netmask.
  end

  newproperty(:source_port_behavior) do
    desc "The snat port behavior."
    newvalues(/^SOURCE_PORT_(PRESERVE|PRESERVE_STRICT|CHANGE)$/)
  end

  newproperty(:translation_target) do
    desc "The snat translation target."
    #TODO validate target and network address.
  end

  newproperty(:vlan) do
    desc "The snat vlan."

    munge do |value|
      raise Puppet::Error, "Puppet::Type::F5_Snat: vlan must be a hash." unless value.is_a? Hash

      unless value.empty?
        value.keys.each do |k|
          raise Puppet::Error, "Puppet::Type::F5_Snat: does not support vlan key #{k}" unless k =~ /^(state|vlans)$/

          # ensure vlan value is an array
          value[k] = value[k].to_a if k == 'vlan'
        end

        raise Puppet::Error, "Puppet::Type::F5_Snat: vlan missing key." unless value.size == 2
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
end
