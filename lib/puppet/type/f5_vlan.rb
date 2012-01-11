Puppet::Type.newtype(:f5_vlan) do
  @doc = "Manages F5 VLAN."

  apply_to_device

  ensurable do
    desc "F5 VLAN resource state. Valid values are present, absent."
    
    defaultto(:present)
    
    newvalue(:present) do
      provider.create
    end
    
    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The VLAN name."
  end

  newproperty(:failsafe_action) do
    desc "The failsafe action for the specified VLAN."
    newvalues(/^HA_ACTION_(NONE|REBOOT|RESTART|FAILOVER|FAILOVER_RESTART|GO_ACTIVE|RESTART_ALL|FAILOVER_ABORT_TRAFFIC_MGT|GO_OFFLINE|GO_OFFLINE_RESTART|GO_OFFLINE_ABORT_TM|GO_OFFLINE_DOWNLINKS|GO_OFFLINE_DOWNLINKS_RESTART)$/)
  end

  newproperty(:failsafe_state) do
    desc "The failsafe state for the specified VLAN."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end

  newproperty(:failsafe_timeout) do
    desc "The failsafe timeout for the specified VLAN."
    newvalues(/^[[:digit:]]+$/)
  end 

  newproperty(:learning_mode) do
    desc "The learning mode for the specified VLAN."
    newvalues(/^LEARNING_MODE_(ENABLE_FORWARD|DISABLE_FORWARD|DISABLE_DROP)$/)
  end 

  newproperty(:mac_masquerade_address) do
    desc "The MAC masquerade address for the specified VLAN."
  end 
  
  newproperty(:member, :array_matching => :all) do
    desc "The list of VLAN members."
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

  newproperty(:mtu) do
    desc "The MTU for the specified VLAN."
    newvalues(/^[[:digit:]]+$/)
  end
  
  newproperty(:source_check_state) do
    desc "The source check state for the specified VLAN."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end 

  newproperty(:static_forwarding, :array_matching => :all) do
    desc "The list of VLAN static forwarding rules."
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
  
  newproperty(:vlan_id) do
    desc "The tag ID for the specified VLAN."
    newvalues(/^[[:digit:]]+$/)
  end
 
end
