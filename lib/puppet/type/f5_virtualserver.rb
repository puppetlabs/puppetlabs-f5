Puppet::Type.newtype(:f5_virtualserver) do
  @doc = "Manage F5 virtualserver."

  apply_to_device

  ensurable do
    desc "Add or delete virtualserver."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newproperty(:port) do
    desc "The virtual server port."
    newvalues(/^\d+$/)
  end

  newproperty(:address) do
    desc "The virtual server ip address."
  end

  newproperty(:wildmask) do
    desc "The virtual server wildmask."
  end

  newproperty(:protocol) do
    desc "The virtual server protocol."
    newvalues(/^PROTOCOL_(ANY|IPV6|ROUTING|NONE|FRAGMENT|DSTOPTS|TCP|UDP|ICMP|ICMPV6|OSPF|SCTP)$/)
  end

  newparam(:name, :namevar=>true) do
    desc "The virtual server name."
  end

  newproperty(:availability_status) do
    desc "The virtual server status."
  end

  newproperty(:enabled_status) do
    desc "The virtual server status."
  end
end
