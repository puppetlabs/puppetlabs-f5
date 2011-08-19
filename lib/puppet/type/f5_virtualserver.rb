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

  newproperty(:availability_status) do
    desc "The virtual server status."
  end

  newproperty(:enabled_status) do
    desc "The virtual server status."
  end
end
