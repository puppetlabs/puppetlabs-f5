Puppet::Type.newtype(:f5_snat) do
  @doc = "Manage F5 snat."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The snat name."
  end

  newproperty(:connection_mirror_state) do
    desc "The connection mirror states for a specified SNATs."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:original_address) do
    desc "The list of original client addresses used to filter the traffic to
    the SNATs."
  end

  newproperty(:source_port_behavior) do
    desc "The source port behavior for the specified SNATs."

    newvalues(/^SOURCE_PORT_(PRESERVE|PRESERVE_STRICT|CHANGE)$/)
  end

  newproperty(:translation_target) do
    desc "The translation targets for the specified SNATs. If the target type
    is SNAT_TYPE_AUTOMAP, then the translation object should be empty."

    #TODO validate target and network address.
    validate do |value|
      fail("Hash required in the form of { type => 'x', translation_object => 'x' }.") unless value.is_a?(Hash)
    end
  end

  newproperty(:vlan) do
    desc "The list of VLANs on which access to the specified SNATs is
    disabled/enabled."

    munge do |value|
      raise Puppet::Error, "Puppet::Type::F5_Snat: vlan must be a hash." unless value.is_a? Hash

      unless value.empty?
        value.keys.each do |k|
          raise Puppet::Error, "Puppet::Type::F5_Snat: does not support vlan key #{k}" unless k =~ /^(state|vlans)$/

          # ensure vlan value is an array
          value[k] = Array(value[k]) if k == 'vlan'
        end

        raise Puppet::Error, "Puppet::Type::F5_Snat: vlan missing key." unless value.size == 2
      end

      value
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
end
