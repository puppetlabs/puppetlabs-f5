require 'ipaddr' # For validation.

Puppet::Type.newtype(:f5_selfip) do
  @doc = 'Manage self IPs within the F5.'

  apply_to_device
  ensurable

  VALID_PARTITION = /^\/.*\//

  newparam(:name, :namevar => true) do
    desc 'The name of the self IP object'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  newproperty(:address) do
    desc 'The IP address of the self IP object'

    validate do |value|
      raise(ArgumentError, 'Address must be a valid IP address.') unless IPAddr.new(value)
    end
  end

  newproperty(:netmask) do
    desc 'Netmask of the self IP object'

    validate do |value|
      raise(ArgumentError, 'Destination must be a valid IP address.') unless IPAddr.new(value)
    end
  end

  newproperty(:vlan) do
    desc 'VLAN or Tunnel name for the self IP object'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  newproperty(:traffic_group) do
    desc 'Traffic group for the self IP object'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  newproperty(:floating_state) do
    desc 'The floating state of the self IP object'

    newvalue('STATE_ENABLED')
    newvalue('STATE_DISABLED')
  end
end
