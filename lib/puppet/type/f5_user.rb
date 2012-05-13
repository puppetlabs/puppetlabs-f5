Puppet::Type.newtype(:f5_user) do
  @doc = "Manages F5 user."

  apply_to_device

  ensurable do
    desc "F5 user resource state. Valid values are present, absent."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The user name."
    newvalues(/^[[:alpha:][:digit:]]+$/)
  end

  newproperty(:user_permission) do
    desc "The list of user permissions."

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

  newproperty(:description) do
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
  end

  newproperty(:login_shell) do
    desc "The login shell for the specified user."
  end

end
