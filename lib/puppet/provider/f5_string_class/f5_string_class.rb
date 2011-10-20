require 'puppet/provider/f5'

Puppet::Type.type(:f5_string_class).provide(:f5_string_class, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 String classes (datagroups)"

  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.wsdl
    'LocalLB.Class'
  end

  def wsdl
    self.class.wsdl
  end

  def members
    m = {}
    @string_class = transport[wsdl].get_string_class([resource[:name]])[0]
    values = transport[wsdl].get_string_class_member_data_value([@string_class])[0]
    @string_class.members.zip(values) {|zipped| m[zipped[0]] = zipped[1]}
    m
  end

  def members=(member_hash)
    member_hash.each do |key,val|
      # iControl doesn't let you add a string class member that already exists
      if @string_class.nil? || ! @string_class.members.include?(key)
        transport[wsdl].add_string_class_member([{:name => resource[:name], :members => [key]}])
      end

      # Set the value
      transport[wsdl].set_string_class_member_data_value([{:name => resource[:name], :members => [key]}], [val])
    end

    # Now remove members that shouldn't be there
    extra_members = if @string_class.nil?
                      []
                    else
                      @string_class.members - member_hash.keys
                    end
    unless extra_members.empty?
      Puppet.debug("Puppet::Provider::F5_String_Class: Removing members #{extra_members.join(',')}")
      transport[wsdl].delete_string_class_member([{:name => resource[:name], :members => [extra_members]}])
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_String_Class: creating F5 string class #{resource[:name]}")

    transport[wsdl].create_string_class([{:name => resource[:name], :members => []}])

    self.members = resource[:members]
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_String_Class: deleting F5 string class #{resource[:name]}")
    @property_hash[:ensure] = :absent
    transport[wsdl].delete_class(resource[:name])
  end

  def exists?
    transport[wsdl].get_string_class_list.include?(resource[:name])
  end
end
