Puppet::Type.newtype(:f5_node) do
  @doc = "Manage F5 node."

  apply_to_device

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The node name. v9.0 API uses IP addresses, v11.0 API uses names."

    validate do |value|
      fail ArgumentError, "#{name} must be a String" unless value.is_a?(String)
      fail ArgumentError, "#{name} must match the pattern /Partition/name" unless value =~ /^\/\w+\/(\w|\d|\.)+$/
    end
  end

  newproperty(:connection_limit) do
    desc "The connection limits for the specified node addresses."

    newvalues(/^\d+$/)
  end

  newproperty(:dynamic_ratio) do
    desc "The dynamic ratios of a node addresses."

    newvalues(/^\d+$/)
  end

  newproperty(:addresses) do
    desc "The IP addresses of the specified node addresses."
  end

  newproperty(:ratio) do
    desc "The ratios for the specified node addresses."

    newvalues(/^\d+$/)
  end

  newproperty(:session_enabled_state) do
    desc "The states that allows new sessions to be established for the
    specified node addresses."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

end
