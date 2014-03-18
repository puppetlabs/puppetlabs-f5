Puppet::Type.newtype(:f5_certificate) do
  @doc = "Manage F5 certificate."

  apply_to_device

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The certificate name."

    validate do |value|
      raise(ArgumentError, "v11.0+ requires a folder or partition in the name, such as /Common/rule") unless value =~ /^\/.*\//
    end
  end

  newproperty(:content) do
    desc "The certificate content in PEM format (sha1 fingerprint)."

    munge do |value|
      resource[:real_content] = value

      # users can provide content with certs and keys, f5 will import both, but we should only compare the cert sha1:
      certs = value.scan(/([-| ]*BEGIN CERTIFICATE[-| ]*.*?[-| ]*END CERTIFICATE[-| ]*)/m).flatten
      raise Puppet::Error, "Puppet::Type::F5_certificate: content does not contain certficates." unless certs.size > 0

      certs_sha1 = certs.collect { |cert|
        Puppet::Util::NetworkDevice::F5.fingerprint(cert)
      }

      "sha1(#{certs_sha1.sort.inspect})"
    end
  end

  newparam(:real_content) do
    desc "Stores actual certificate PEM-formatted content."
  end

  newparam(:mode) do
    desc "The certificate management mode. An enumerated type that will
    describe what mode of key/cert management to use."

    defaultto("MANAGEMENT_MODE_DEFAULT")
    newvalues(/^MANAGEMENT_MODE_(DEFAULT|WEBSERVER|EM|IQUERY|IQUERY_BIG3D)$/)
  end
end
