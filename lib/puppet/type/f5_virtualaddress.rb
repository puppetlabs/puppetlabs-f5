Puppet::Type.newtype(:f5_virtualaddress) do
  @doc = "Manage F5 virtual address."

  apply_to_device

  ensurable do
    desc "F5 virtual address resource state. Valid values are present, absent."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The IP address."

    newvalues(/^[[:digit:]\.]+$/)
  end

  newproperty(:connection_limit) do
    desc "The connection limits for the specified virtual addresses."

    newvalues(/^\d+$/)
  end

  newproperty(:arp_state) do
    desc "The states that enable ARP on the specified virtual address."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:enabled_state) do
    desc "The states that allow new connections to be established to the
    specified virtual addresses."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:is_floating_state) do
    desc "The states that add floating self IPs for the specified virtual
    addresses, shared by both units in a cluster."
     
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:route_advertisement_state) do
    desc "The states that allow the specified virtual addresses to be
    advertised into routing protocols."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:status_dependency_scope) do
    desc "The scopes of the specified virtual addresses."

    newvalues(/^VIRTUAL_ADDRESS_STATUS_DEPENDENCY_(NONE|ANY|ALL)$/)
  end
end
