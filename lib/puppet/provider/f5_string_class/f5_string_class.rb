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
    Array(transport[wsdl].get(:get_string_class_list)).collect do |name|
      new(:name => name, :ensure => :present)
    end
  end

  def self.prefetch(resources)
    string_class = instances
    resources.keys.each do |name|
      if provider = string_class.find { |string| string.name == name }
        resources[name].provider = provider
      end
    end
  end

  def members
    string_class = {}

    key = transport[wsdl].get(:get_string_class, { class_names: { items: resource[:name] } })
    message = { class_members: { items: { name: key[:name], members: { items: key[:members][:item] }}}}
    values = transport[wsdl].get(:get_string_class_member_data_value, message)

    items = Array(key[:members][:item])
    vals  = Array(values)

    items.zip(vals) do |zipped|
      zipped[1] == nil ? string_class[zipped[0]] = '' : string_class[zipped[0]] = zipped[1]
    end
    string_class
  end

  def members=(value)
    new_members = value.reject {|k,v| members.has_key?(k) }
    current_members = value.select {|k,v| members.has_key?(k) }
    remove_members  = members.reject {|k,v| value.has_key?(k) }

    if ! new_members.empty?
      message = { class_members: { items: { name: resource[:name], members: { items: new_members.keys }}}}
      transport[wsdl].call(:add_string_class_member, message: message)

      new_members.each do |member, content|
        message = {
          class_members: {
            items: {
              name: resource[:name], members: { items: member }
            }
          },
          values: {
            items: {
              items: content
            }
          }
        }
        transport[wsdl].call(:set_string_class_member_data_value, message: message)
      end
    end

    if ! current_members.empty?
      current_members.each do |member, content|
        if value[member] != members[member]
          message = {
            class_members: {
              items: {
                name: resource[:name], members: { items: member }
              }
            },
            values: {
              items: {
                items: content
              }
            }
          }
          transport[wsdl].call(:set_string_class_member_data_value, message: message)
        end
      end
    end

    if ! remove_members.empty?
      message = { class_members: { items: { name: resource[:name], members: { items: remove_members.keys }}}}
      transport[wsdl].call(:delete_string_class_member, message: message)
    end
  end

  def create
    @string_class = {}
    message = { classes: { items: { name: resource[:name], members: { items: [] }}}}
    transport[wsdl].call(:create_string_class, message: message)
    self.members = resource[:members]
    @property_hash[:ensure] = :present
  end

  def destroy
    transport[wsdl].call(:delete_class, message: { classes: { items: resource[:name] }})
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
