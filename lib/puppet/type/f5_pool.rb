Puppet::Type.newtype(:f5_pool) do
  @doc = "Manage F5 pool."

  ensurable do
    desc "Add or delete pool."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The pool name."
  end

  newproperty(:member) do
    desc "The pool member."
  end

  newproperty(:minimum_active_member) do
    desc "The pool member."
  end

  newproperty(:minimum_up_member) do
    desc "The pool member."
  end

  newproperty(:minimum_up_member_action) do
    desc "The pool member."
  end

  newproperty(:minimum_up_member_enabled_state) do
    desc "The pool member."
  end

  newproperty(:version) do
    desc "The pool member."
  end
end
