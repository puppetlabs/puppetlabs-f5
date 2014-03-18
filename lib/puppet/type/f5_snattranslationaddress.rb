Puppet::Type.newtype(:f5_snattranslationaddress) do
  @doc = "Manage F5 snat translation address."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The snat translation address name."
  end

  newparam(:addresses) do
    desc "The IP addresses of the specified SNAT translation address"
  end

  newproperty(:arp_state) do
    desc "The ARP states for the specified tranlation SNAT address."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:connection_limit) do
    desc "The connection limits of the specified original SNAT translation
    address."

    newvalues(/^\d+$/)
  end

  newproperty(:enabled_state) do
    desc "The state of a SNAT translation address."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:ip_timeout) do
    desc "The IP idle timeouts of the specified SNAT translation address."

    newvalues(/^\d+$/)
  end

  newproperty(:tcp_timeout) do
    desc "The TCP idle timeouts of the specified SNAT translation address."

    newvalues(/^\d+$/)
  end

  newproperty(:udp_timeout) do
    desc "The UDP idle timeouts of the specified SNAT translation addresses."

    newvalues(/^\d+$/)
  end
end
