require 'puppet/property/list'
Puppet::Type.newtype(:f5_snatpool) do
  @doc = "Manage F5 snatpool."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The snatpool name."
  end

  newparam(:membership) do
    defaultto :inclusive
  end

  newproperty(:member, :array_matching => :all) do
    desc "The list of members belonging to the specified SNAT pools."

    validate do |value|
      unless value =~ /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/
        raise "A valid IP address is required for the member property."
      end
    end
  end

end
