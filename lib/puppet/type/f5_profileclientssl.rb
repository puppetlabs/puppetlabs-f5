Puppet::Type.newtype(:f5_profileclientssl) do
  @doc = "Manage F5 Client SSL profiles."

  apply_to_device

  ensurable do
    desc "Add or delete Client SSL profile."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The Client SSL profile name."
  end

  newproperty(:certificate_file) do
    desc "The certificate filenames to be used by BIG-IP acting as an SSL
    server."
  end

  newproperty(:key_file) do
    desc "The key filenames to be used by BIG-IP acting as an SSL server. If a
    full path is not specified, the file name is relative to
    /config/ssl/ssl.key."
  end

  newproperty(:ca_file) do
    desc "The CA to use to validate client certificates"
  end

  newproperty(:client_certificate_ca_file) do
    desc "The CA to use to validate client certificates"
  end

  newproperty(:peer_certification_mode) do
    desc "The peer certification modes for the specified client SSL profiles."
  end
end
