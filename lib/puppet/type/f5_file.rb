Puppet::Type.newtype(:f5_file) do
  @doc = "Manages F5 file."

  apply_to_device

  ensurable do
    desc "F5 file resource state. Valid values are present, absent."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:path, :namevar=>true) do
    desc "The path to file on F5 device, must be absolute file path."

    validate do |value|
      raise Puppet::Error, "Puppet::Type::F5_file: file path must be absolute path." unless value == File.expand_path(value)
    end
  end

  newproperty(:content) do
    desc "The file content."

    defaultto('')

    munge do |value|
      resource[:real_content] = value
      value = "md5(#{Digest::MD5.hexdigest(value)})"
    end
  end

  newparam(:real_content) do
    desc "The file's real content."
  end
end
