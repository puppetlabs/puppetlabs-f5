Puppet::Type.newtype(:f5_certificate) do
  @doc = "Manage F5 certificate."

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

  #newparam(:file) do
  #  desc "The cerficate file (content)."
  #end
  #
  newparam(:mode) do
    desc "The certificate management mode type."

  end

  #newproperty(:cert_info) do
  #  desc "some demo."
  #end
end
