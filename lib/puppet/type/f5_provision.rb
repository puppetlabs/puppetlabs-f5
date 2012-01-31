Puppet::Type.newtype(:f5_provision) do
  @doc = "Manages F5 provision."

  apply_to_device

  newparam(:name, :namevar=>true) do
    desc "The module name to provision with."
    newvalues(/^TMOS_MODULE_(ASM|SAM|WAM|PSM|WOM|LC|LTM|GTM|WOML|APML|EM|VCMP|TMOS|HOST|UI|MONITORS|AVR)$/)
  end

  newproperty(:custom_cpu_ratio) do
    desc "The CPU ratio for the given TMOS module."
    # The newvalues method doesnt support neither ranges nor arrays.
    newvalues(/^\d+$/)
    validate do |value|
      raise Puppet::Error, "Puppet::Type::F5_provision: value must be comprised between 0 and 255" if value < 0 || value > 255
    end
    defaultto 0
  end
  
  newproperty(:custom_disk_ratio) do
    desc "The disk ratio for the given TMOS module."
    # The newvalues method doesnt support neither ranges nor arrays.
    newvalues(/^\d+$/)
    validate do |value|
      raise Puppet::Error, "Puppet::Type::F5_provision: value must be comprised between 0 and 255" if value < 0 || value > 255
    end
    defaultto 0
  end

  newproperty(:custom_memory_ratio) do
    # The newvalues method doesnt support neither ranges nor arrays.
    newvalues(/^\d+$/)
    validate do |value|
      raise Puppet::Error, "Puppet::Type::F5_provision: value must be comprised between 0 and 255" if value < 0 || value > 255
    end
    defaultto 0
  end
  
  newproperty(:level) do
    desc "The provisioning level for the given TMOS module."
    newvalues(/^PROVISION_LEVEL_(NONE|MINIMUM|NOMINAL|DEDICATED|CUSTOM)$/)
  end
  
  autorequire(:f5_license) do
    ["license"]
  end
end