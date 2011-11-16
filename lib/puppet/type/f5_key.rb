require 'puppet/util/network_device/f5'

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

  newproperty(:content) do
    desc "The key content in PEM format."

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
    desc "The actual key content."
  end

  newparam(:mode) do
    desc "They key management mode."
    defaultto("MANAGEMENT_MODE_DEFAULT")
    newvalues(/^MANAGEMENT_MODE_(DEFAULT|WEBSERVER|EM|IQUERY|IQUERY_BIG3D)$/)
  end
end
