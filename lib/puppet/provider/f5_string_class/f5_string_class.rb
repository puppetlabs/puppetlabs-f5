require 'puppet/provider/f5'

Puppet::Type.type(:f5_string_class).provide(:f5_string_class, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 String classes (datagroups)"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.Class'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_string_class_list.collect do |name|
      new(:name => name)
    end
  end

  def string_class
    return @string_class if @string_class

    @string_class = {}
    key = transport[wsdl].get_string_class([resource[:name]]).first
    value = transport[wsdl].get_string_class_member_data_value([key]).first
    key.members.zip(value) {|zipped| @string_class[zipped[0]] = zipped[1]}
    @string_class
  end

  def members
    string_class
  end

  def members=(value)
    # F5 modify_string_class only changes the members and not the member value,
    # hence the much more complicated implimentation below.
    # transport[wsdl].modify_string_class( [{ :name => resource[:name], :members => resource[:members] }] )
    new_members     = value.keys - string_class.keys
    current_members = value.keys & string_class.keys
    remove_members  = string_class.keys - value.keys

    new_members.each do |member|
      Puppet.debug("Puppet::Provider::F5_String_Class: adding members #{new_members.join(', ')}")

      transport[wsdl].add_string_class_member( [{ :name => resource[:name], :members => [member]}] )
      transport[wsdl].set_string_class_member_data_value( [{ :name => resource[:name], :members => [member] }], value[member])
    end

    current_members.each do |member|
      if value[member] != string_class[member]
        Puppet.debug("Puppet::Provider::F5_String_Class: modifying members #{new_members.join(', ')}")
        transport[wsdl].set_string_class_member_data_value( [{ :name => resource[:name], :members => [member] }], value[member])
      end
    end

    unless remove_members.empty?
      Puppet.debug("Puppet::Provider::F5_String_Class: removing members #{remove_members.join(', ')}")
      transport[wsdl].delete_string_class_member( [{ :name => resource[:name], :members => remove_members }] )
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_String_Class: creating F5 string class #{resource[:name]}")

    @string_class = {}
    transport[wsdl].create_string_class([{:name => resource[:name], :members => []}])
    self.members = resource[:members]
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_String_Class: deleting F5 string class #{resource[:name]}")

    transport[wsdl].delete_class(resource[:name])
  end

  def exists?
    transport[wsdl].get_string_class_list.include?(resource[:name])
  end
end
