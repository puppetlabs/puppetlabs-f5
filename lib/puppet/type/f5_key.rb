Puppet::Type.newtype(:f5_key) do
  @doc = "Manage F5 key."

  ensurable do
    desc "Add or delete key."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The key name."
  end
end
