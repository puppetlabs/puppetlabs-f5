Puppet::Type.newtype(:f5_node) do
  @doc = "Manage F5 node."

  apply_to_device

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The node name. v9.0 API uses IP addresses, v11.0 API uses names."

    newvalues(/^[[:alpha:][:digit:]\/]+$/)
  end

  newproperty(:connection_limit) do
    desc "The connection limits for the specified node addresses."

    newvalues(/^\d+$/)
  end

  newproperty(:dynamic_ratio) do
    desc "The dynamic ratios of a node addresses."

    newvalues(/^\d+$/)
  end

  newparam(:addresses) do
    desc "The IP addresses of the specified node addresses."
  end

  # Current iControl gem get_monitor_association is broken:
  # /System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib/ruby/1.8/wsdl/xmlSchema/simpleType.rb:66:in `check_restriction': {urn:iControl}LocalLB.AddressType: cannot accept '' (XSD::ValueSpaceError)

  # newproperty(:monitor_association) do
  #   desc "The monitor instance information for the specified node addresses."
  # end

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
