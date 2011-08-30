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
    #TODO validate vlan state.
  end
end
