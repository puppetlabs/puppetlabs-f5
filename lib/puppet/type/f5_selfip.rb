Puppet::Type.newtype(:f5_selfip) do
  @doc = "Manages F5 Self IP."

  apply_to_device

  ensurable do
    desc "F5 self IP resource state. Valid values are present, absent."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The self IP address."
    newvalues(/^[0-9A-Fa-f\.\:]+$/)
  end

  newproperty(:floating_state) do
    desc "The floating_state for the specified self IP."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:netmask) do
    desc "The net mask for the specified self IP."
    newvalues(/^[0-9A-Fa-f\.\:]+$/)
  end

  newproperty(:unit_id) do
    desc "The unit ID for the specified self IP."
    newvalues(/^[[:digit:]]+$/)
  end

  newproperty(:vlan) do
    desc "The VLAN for the specified self IP."
  end

  autorequire(:f5_vlan) do
    if f5_vlan = self[:vlan]
      f5_vlan
    end
  end

end
