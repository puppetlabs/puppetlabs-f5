require 'openssl'
require 'digest/sha1'

Puppet::Type.newtype(:f5_certificate) do
  @doc = "Manage F5 certificate."

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

  newparam(:real_content) do
    desc "Store actual PEM file content."
  end

  newproperty(:content) do
    desc "The cerficate file PEM content (fingerprint compared)."

    munge do |value|
      resource[:real_content] = value
      "sha1(#{Digest::SHA1.hexdigest(OpenSSL::X509::Certificate.new(value).to_der)}"
    end
  end

  newparam(:mode) do
    desc "The certificate management mode type."

    defaultto("MANAGEMENT_MODE_DEFAULT")

    newvalues(/^MANAGEMENT_MODE_(DEFAULT|WEBSERVER|EM|IQUERY|IQUERY_BIG3D)$/)
  end
end
