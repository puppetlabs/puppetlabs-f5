Puppet::Type.newtype(:f5_string_class) do
  @doc = "Manages F5 String classes (datagroups)"

  apply_to_device

  ensurable do
    desc "F5 Sting Class resource state. Valid values are present, absent."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The string class name."
  end

  newproperty(:members) do
    desc "The string class members."

    validate do |value|
      raise Puppet::Error, "Puppet::Type::F5_String_Class: members property must be a hash." unless value.is_a? Hash
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
end
