Puppet::Type.newtype(:f5_trunk) do
  @doc = "Manages F5 trunk."

  apply_to_device

  ensurable do
    desc "F5 trunk resource state. Valid values are present, absent."
    
    defaultto(:present)
    
    newvalue(:present) do
      provider.create
    end
    
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The trunk name."
  end

  newproperty(:active_lacp_state) do
    desc "The active or passive LACP state for the specified trunk."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end

  newproperty(:distribution_hash_option) do
    desc "The frame distribution hashing option for the specified trunk."
    newvalues(/^DISTRIBUTION_HASH_OPTION_(DST_MAC|SRC_DST_MAC|SRC_DST_MAC_IP)$/)
  end

  newproperty(:interface, :array_matching => :all) do
    desc "The member interface list for the specified trunk."
    def insync?(is)
      is.eql?(@should)
    end
    def should_to_s(newvalue)
      newvalue.inspect
    end
    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
  
  newproperty(:lacp_enabled_state) do
    desc "The LACP state for the specified trunk."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end 

  newproperty(:lacp_timeout_option) do
    desc "The LACP timeout option for the specified trunk."
    newvalues(/^LACP_TIMEOUT_(LONG|SHORT)$/)
  end 

  newproperty(:link_selection_policy) do
    desc "The link selection policy for the specified trunk."
    newvalues(/^LINK_SELECTION_(AUTO|MAXIMUM_BANDWIDTH)$/)
  end 
  
  newproperty(:stp_enabled_state) do
    desc "The STP state for the specified trunk."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end
  
  newproperty(:stp_protocol_detection_reset_state) do
    desc "The STP protocol detection reset state for the specified trunk."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end
 
end