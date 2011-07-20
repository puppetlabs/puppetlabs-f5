Puppet::Type.newtype(:f5_node) do
  @doc = "Manage F5 node."

  ensurable do
    desc "Add or delete node."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The node name."
  end

  newproperty(:connection_limit, :array_matching => :all) do
    desc "The node connection limit."
    defaultto([0, 0])
  end

  newproperty(:dynamic_ratio) do
    desc "The node dynamic ratio."
    newvalues(/^\d+$/)
  end

  #newproperty(:monitor_association) do
  #  desc "The node monitor association."
  #  #newvalues(/^STATE_(DISABLED|ENABLED)$/)
  #end

  #newproperty(:monitor_state) do
  #  desc "The node monitor state."
    #newvalues(/^\d+$/)
  #end

  newproperty(:ratio) do
    desc "The node ratio."
    newvalues(/^\d+$/)
  end

  newproperty(:screen_name) do
    desc "The node screen_name."
  end

  newproperty(:session_enabled_state) do
    desc "The node gateway failsafe device."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end
end
