Puppet::Type.newtype(:f5_key) do
  @doc = "Manage F5 key."

  apply_to_device

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

  newproperty(:key_type) do
    desc "The key type."
    newvalues(/^KTYPE_(RSA|DSA)_(PRIVATE|PUBLIC)$/)
  end

  newproperty(:security) do
    desc "The key security purpose."
    newvalues(/^STYPE_(NORMAL|FIPS|PASSWORD)/)
  end

  newparam(:managementmode) do
    desc "They key management mode."

    defaultto("MANAGEMENT_MODE_DEFAULT")

    newvalues(/^MANAGEMENT_MODE_(DEFAULT|WEBSERVER|EM|IQUERY|IQUERY_BIG3D)$/)
  end

  newparam(:content) do
    desc "They key content in PEM format."
  end
end
