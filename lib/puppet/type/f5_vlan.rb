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
    newvalues(/^[[:digit:][:alpha:]]+$/)
  end

  newproperty(:description) do
    desc "The description for the specified VLAN."
  end
  
  newproperty(:member) do
    desc "The list of VLAN members."

    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # Comparison of hashes
      return false unless is.class == Hash and should.class == Hash and is.keys.sort == should.keys.sort
      should.each do |k, v|
        if v.is_a?(Hash)
          v.each do |l, w|
            # so far all member values are int
            return false unless is[k].include?(l).to_s and is[k][l] == w.to_s
          end
        end
      end
      true
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
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
  
  newproperty(:mtu) do
    desc "The MTU for the specified VLAN."
    newvalues(/^[[:digit:]]+$/)
  end
  
  newproperty(:source_check_state) do
    desc "The VLAN for the specified VLAN."
    newvalues(/^STATE_(ENABLED|DISABLED)$/)
  end 

  #newproperty(:static_forwarding_description) do
  #  desc "The VLAN for the specified VLAN."
  #end 

  newproperty(:vlan_id) do
    desc "The tag ID for the specified VLAN."
    newvalues(/^[[:digit:]]+$/)
  end 

  
end
