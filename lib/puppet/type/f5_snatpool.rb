Puppet::Type.newtype(:f5_snatpool) do
  @doc = "Manage F5 snatpool."

	apply_to_device

  ensurable do
    desc "Add or delete snatpool."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The snatpool name."
  end

  newproperty(:member, :array_matching => :all) do
    desc "The snatpool member."

    #munge do |value|
    #  Array(value)
    #end
  end
end
