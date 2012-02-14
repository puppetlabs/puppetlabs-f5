require 'puppet/provider/f5'

Puppet::Type.type(:f5_external_class).provide(:f5_external_class, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 external classes (datagroups)"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.Class'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_external_class_list.collect do |ext|
      new(:name => ext.class_name)
    end
  end

  methods = [
    'file_format',
    'file_mode',
    'file_name',
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_external_class_#{method}".to_sym)
        profile_string = transport[wsdl].send("get_external_class_#{method}", resource[:name]).first
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |profile_string|
      if transport[wsdl].respond_to?("set_external_class_#{method}".to_sym)
        transport[wsdl].send("set_external_class_#{method}", resource[:name], [resource[method.to_sym]])
      end
    end
  end

  def data_separator
    transport[wsdl].get_data_separator(resource[:name]).first
  end

  def data_separator=(value)
    transport[wsdl].set_data_separator(resource[:name], [ resource[:data_separator] ])
  end

  def type
    transport[wsdl].get_class_type(resource[:name]).first
  end

  def type=(value)
    transport[wsdl].set_class_type(resource[:name], [ resource[:type] ])
  end

  def create
    # F5 external class can not conflict with address, string, or value class
    # namevar.  Since Puppet can not enforce unique resource names, it is not
    # safe to delete the class.
    Puppet.debug("Puppet::Provider::F5_external_class: creating F5 external class #{resource[:name]}")

    metainfo = {
                 :class_name  => resource[:name],
                 :class_type  => resource[:type],
                 :file_name   => resource[:file_name],
                 :file_mode   => resource[:file_mode],
                 :file_format => resource[:file_format]
                }

    transport[wsdl].create_external_class([metainfo])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_external_class: deleting F5 external class #{resource[:name]}")

    transport[wsdl].delete_class(resource[:name])
  end

  def refresh
    Puppet.debug("Puppet::Provider::F5_external_class: refreshing F5 external class #{resource[:name]}")
    transport[wsdl].set_external_class_file_name(resource[:name], resource[:file_name])
  end

  def exists?
    ext_class = transport[wsdl].get_external_class_list.collect{ |ext| ext.class_name }
    ext_class.include?(resource[:name])
  end
end
