Puppet::Type.newtype(:f5_license) do
  @doc = "Manages F5 license file."

  apply_to_device

  newparam(:name, :namevar=>true) do
    desc "The license name. Must be fixed to 'license'."
    newvalues(/^license$/)
  end

  newproperty(:license_file_data) do
    desc "The license file data."
    munge do |value|
      resource[:license_file_content]=value
      value = "md5(#{Digest::MD5.hexdigest(value)})"
    end
  end

  newparam(:license_file_content) do
    desc "The license's real content."
  end

end
