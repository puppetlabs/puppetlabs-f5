Puppet::Type.newtype(:f5_provision) do
  @doc = "Manages F5 provision."

  apply_to_device

  newparam(:name, :namevar=>true) do
    desc "The module name to provision with."
    newvalues(/^TMOS_MODULE_(ASM|SAM|WAM|PSM|WOM|LC|LTM|GTM|WOML|APML|EM|VCMP|TMOS|HOST|UI|MONITORS|AVR)$/)
  end

  newproperty(:custom_cpu_ratio) do
    desc "The CPU ratio for the given TMOS module."
    newvalues(/^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/)
    defaultto 0
  end

  newproperty(:custom_memory_ratio) do
    newvalues(/^([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$/)
    defaultto 0
  end

  newproperty(:level) do
    desc "The provisioning level for the given TMOS module."
    newvalues(/^PROVISION_LEVEL_(NONE|MINIMUM|NOMINAL|DEDICATED|CUSTOM)$/)
  end

end
