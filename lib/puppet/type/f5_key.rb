Puppet::Type.newtype(:f5_key) do
  @doc = "Manage F5 key."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The key name."

    validate do |value|
      raise(ArgumentError, "v11.0+ requires a folder or partition in the name, such as /Common/rule") unless value =~ /^\/.*\//
    end
  end

  newproperty(:content) do
    desc "The cerficate key in PEM format (sha1 fingerprint)."

    # Since we won't be able to decode private key, calculating sha1 of the content instead.
    munge do |value|
      resource[:real_content] = value

      # users can provide content with certs and keys, f5 will import both, but we should only compare the key sha1:
      keys = value.scan(/([-| ]*BEGIN [R|D]SA (?:PRIVATE|PUBLIC) KEY[-| ]*.*?[-| ]*END [R|D]SA (?:PRIVATE|PUBLIC) KEY[-| ]*)/m).flatten

      keys_sha1 = keys.collect { |key|
        Puppet::Util::NetworkDevice::F5.fingerprint(key)
      }

      "sha1(#{keys_sha1.sort.inspect})"
    end
  end

  newparam(:real_content) do
    desc "Stores actual key PEM-formatted content."
  end

  newparam(:mode) do
    desc "The key management mode. An enumerated type that will describe what
    mode of key/cert management to use."

    defaultto("MANAGEMENT_MODE_DEFAULT")
    newvalues(/^MANAGEMENT_MODE_(DEFAULT|WEBSERVER|EM|IQUERY|IQUERY_BIG3D)$/)
  end
end
