Puppet::Type.newtype(:f5_user) do
  @doc = "Manages F5 user."

  feature :descriptions, "Supports the ability to set user descriptions."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The user name."
    newvalues(/^[[:alpha:][:digit:]]+$/)
  end

  newproperty(:user_permission) do
    desc "The list of user permissions (API >=V11)."
    validate do |value|
      raise Puppet::Error.new("Property 'user_permission' must be a Hash.") unless value.class == Hash
      value.values.each do |perm|
        raise Puppet::Error.new("'#{perm}' is not a valid permission role value.") unless perm =~ /^USER_ROLE_(ADMINISTRATOR|TRAFFIC_MANAGER|GUEST|ASM_POLICY_EDITOR|MANAGER|EDITOR|APPLICATION_EDITOR|CERTIFICATE_MANAGER|USER_MANAGER|RESOURCE_ADMINISTRATOR|ASM_EDITOR|ADVANCED_OPERATOR)$/
      end
    end
    def should_to_s(newvalue)
      newvalue.inspect
    end
    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:description, :required_features => :descriptions) do
    desc "The description for the specified user. (API >= v10)"
  end

  newproperty(:fullname) do
    desc "The full name for the specified user."
  end

  newproperty(:password) do
    desc "The password for the specified user."
    validate do |value|
      unless value['is_encrypted'] == true or value['is_encrypted'] == false
        raise Puppet::Error.new("#{value['is_encrypted']} is not a valid is_encrypted value which must be true or false.")
      end
    end
    def should_to_s(newvalue)
      newvalue.inspect
    end
    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:login_shell) do
    desc "The login shell for the specified user."
  end

end
