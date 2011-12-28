require 'puppet/property/list'
Puppet::Type.newtype(:f5_snatpool) do
  @doc = "Manage F5 snatpool."

  apply_to_device

  ensurable do
    desc "F5 snatpool resource state. Valid values are present, absent."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The snatpool name."
  end

  newparam(:membership) do
    defaultto :inclusive
  end

  newproperty(:member, :parent => Puppet::Property::List) do
    desc "The list of members belonging to the specified SNAT pools."

    munge do |value|
      if value =~ /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/ then
        return value
      else
        raise "A valid IP address is required for the member property."
      end
    end
  end
end
