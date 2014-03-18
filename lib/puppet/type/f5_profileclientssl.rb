Puppet::Type.newtype(:f5_profileclientssl) do
  @doc = "Manage F5 Client SSL profiles."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The Client SSL profile name."
  end

  newproperty(:certificate_file) do
    desc "The certificate filenames to be used by BIG-IP acting as an SSL
    server."

    munge do |value|
      Hash[value.map{|(k,v)| [k.to_sym,v]}]
    end
  end

  newproperty(:key_file) do
    desc "The key filenames to be used by BIG-IP acting as an SSL server. If a
    full path is not specified, the file name is relative to
    /config/ssl/ssl.key."

    munge do |value|
      Hash[value.map{|(k,v)| [k.to_sym,v]}]
    end
  end

  newproperty(:ca_file) do
    desc "The CA to use to validate client certificates"

    munge do |value|
      Hash[value.map{|(k,v)| [k.to_sym,v]}]
    end
  end

  newproperty(:client_certificate_ca_file) do
    desc "The CA to use to validate client certificates"

    munge do |value|
      Hash[value.map{|(k,v)| [k.to_sym,v]}]
    end
  end

  newproperty(:peer_certification_mode) do
    desc "The peer certification modes for the specified client SSL profiles."

    munge do |value|
      Hash[value.map{|(k,v)| [k.to_sym,v]}]
    end
  end

  newproperty(:chain_file) do
    desc "The certificate chain filenames for the specified client SSL profiles."

    munge do |value|
      Hash[value.map{|(k,v)| [k.to_sym,v]}]
    end
  end
end
