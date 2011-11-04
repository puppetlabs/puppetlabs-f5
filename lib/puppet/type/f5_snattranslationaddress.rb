Puppet::Type.newtype(:f5_snattranslationaddress) do
  @doc = "Manage F5 snat translation address."

  apply_to_device

  ensurable do
    desc "Add or delete snat translation address."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The snat translation address name."
  end

  newproperty(:arp_state) do
    desc "The snat translation address arp state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:connection_limit) do
    desc "The snat translation address connection limit."
    newvalues(/^\d+$/)
  end

  newproperty(:enabled_state) do
    desc "The snat translation enabled state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:ip_timeout) do
    desc "The snat translation address ip timeout."
    newvalues(/^\d+$/)
  end

  newproperty(:tcp_timeout) do
    desc "The snat translation address tcp timeout."
    newvalues(/^\d+$/)
  end

  newproperty(:udp_timeout) do
    desc "The snat translation address udp timeout."
    newvalues(/^\d+$/)
  end

  newproperty(:unit_id) do
    desc "The snat translation address unit id."
    newvalues(/^\d+$/)
  end
end
