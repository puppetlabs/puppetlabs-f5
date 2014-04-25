Puppet::Type.newtype(:f5_rule) do
  @doc = "Manage F5 rule."

  apply_to_device
  ensurable

  newparam(:name, :namevar => true) do
    desc 'The rule name.'

    validate do |value|
      raise(ArgumentError, "v11.0+ requires a folder or partition in the name, such as /Common/rule") unless value =~ /^\/.*\//
    end
  end

  newproperty(:definition) do
    desc 'The rule definition.'
  end
end
