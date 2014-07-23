require 'ipaddr' # For validation.

Puppet::Type.newtype(:f5_vlan) do
  @doc = 'Manage self IPs within the F5.'

  apply_to_device
  ensurable

  VALID_PARTITION = /^\/.*\//

  newparam(:name, :namevar => true) do
    desc 'The name of the VLAN object'

    validate do |value|
      raise(ArgumentError, "Must match pattern of /Partition/ObjectName") unless value =~ VALID_PARTITION
    end
  end

  newproperty(:vlan_id) do
    desc 'The ID of the VLAN object'

    newvalues(/^\d+$/)
  end

  newproperty(:members, :array_matching => :all) do
    desc 'The list of interfaces/trunks that will be members of the VLAN.'
    required_keys = ['member_name','member_type','tag_state']

    validate do |value|
      value = [ value ] unless value.is_a?(Array)

      value.each do |hash|
        unless required_keys.any? { |k| hash.key?(k) }
          raise Puppet::Error, "Puppet::Type::F5_Vlan_Class: members property hash must include keys ${required_keys.join(', ')}."
        end
        unless hash['member_type'] =~ /^MEMBER_(INTERFACE|TRUNK)$/
          raise Puppet::Error, "Puppet::Type::F5_Vlan_Class: members property hash key 'member_type' must have value 'MEMBER_INTERFACE' or 'MEMBER_TRUNK'."
        end
        unless hash['tag_state'] =~ /^MEMBER_(TAGGED|UNTAGGED)$/
          raise Puppet::Error, "Puppet::Type::F5_Vlan_Class: members property hash key 'tag_state' must have value 'MEMBER_TAGGED' or 'MEMBER_UNTAGGED'."
        end
      end
    end

    def insync?(is)
      is = [ is ] unless is.is_a?(Array)

      is.sort!
      should = @should.sort

      # For some reason `is` hash keys are symbols and `@should` hash keys
      # are strings. We want strings, so transform them.
      is.each do |element|
        element.keys.each do |key|
          element[key.to_s] = element.delete(key)
        end
      end

      return true if is == should
      false
    end

    def should_to_s(newvalue)
      newvalue
    end

    def is_to_s(currentvalue)
      currentvalue
    end
  end

  newproperty(:failsafe_state) do
    desc 'Failsafe state value for the VLAN.'
    defaultto 'STATE_DISABLED'

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:timeout) do
    desc 'Failsafe timeout'
    defaultto '90'

    newvalues(/^\d+$/)
  end
end
