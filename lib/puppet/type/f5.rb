Puppet::Type.newtype(:f5) do
  @doc = "Generic F5 type."

  newparam(:name, :namevar=>true) do
    desc "The pool name."
  end
end
