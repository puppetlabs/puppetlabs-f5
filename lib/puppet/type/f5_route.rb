require 'ipaddr' # For validation.

Puppet::Type.newtype(:f5_route) do
  @doc = 'Manage static routes within the F5.'

  apply_to_device
  ensurable

  VALID_PARTITION = /^\/.*\//

  newparam(:name, :namevar => true) do
    desc 'The name of the routing object.'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  newproperty(:description) do
    desc 'Description of the route.'

    validate do |value|
      raise(ArgumentError, 'Description must be a string.') unless value.is_a?(String)
    end
  end

  newproperty(:destination) do
    desc 'Destination of the route'

    validate do |value|
      raise(ArgumentError, 'Destination must be a valid IP address.') unless IPAddr.new(value)
    end
  end

  newproperty(:netmask) do
    desc 'Netmask of the route'

    validate do |value|
      raise(ArgumentError, 'Destination must be a valid IP address.') unless IPAddr.new(value)
    end
  end

  newproperty(:mtu) do
    desc 'MTU of the route'

    newvalues(/\d+/)
  end

  newproperty(:gateway) do
    desc 'Gateway of the route'

    validate do |value|
      next if value == 'reject'
      raise(ArgumentError, 'Destination must be a valid IP address.') unless IPAddr.new(value)
    end
  end

  newproperty(:pool) do
    desc 'Pool to route to.'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  newproperty(:vlan) do
    desc 'VLAN to route to.'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  validate do
    if self[:vlan] and self[:pool]
      raise(ArgumentError, "Cannot declare a vlan and pool at the same time.")
    end
    if self[:pool] and self[:gateway]
      raise(ArgumentError, "Cannot declare a pool and a gateway at the same time.")
    end
    if self[:gateway] and self[:gateway] != 'reject'
      if IPAddr.new(self[:gateway]).ipv6? and self[:vlan].nil?
        raise(ArgumentError, "An IPv6 gateway requires you to set a VLAN.")
      end
    end
  end

end
