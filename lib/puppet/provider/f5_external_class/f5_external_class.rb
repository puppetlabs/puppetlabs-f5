require 'puppet/provider/f5'

Puppet::Type.type(:f5_external_class).provide(:f5_external_class, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 external classes (datagroups)"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.DataGroupFile'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    instances = []

    begin
      transport[wsdl].call(:get_external_class_list_v2)[:get_external_class_list_response][:return].collect do |ext|
        instances << new(:name => ext.class_name)
      end
    rescue Exception => e
      Puppet.debug("Puppet::Provider::F5_external_class:  No external classes found.  Exception: #{e.message}")
    end

    instances
  end

  methods = [
    'file_format',
    'file_mode',
    'file_name',
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      symbol = "get_external_class_#{method}_v2".to_sym
      if transport[wsdl].operations.include?(symbol)
        response = transport[wsdl].call(symbol)
      end
    end
    return response if response
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      symbol = "set_external_class_#{method}_v2".to_sym
      if transport[wsdl].operations.include?(symbol)
        message = { class_names: {item: resource[:names]}, file_names: {item: resource[method.to_sym]}}
        transport[wsdl].call(symbol, message: message)
      end
    end
  end

  def data_separator
    transport[wsdl].call(:get_data_separator, message: { item: resource[:name] })
  end

  def data_separator=(value)
    message = { files: { item: resource[:name] }, separators: { item: resource[:data_separator] } }
    transport[wsdl].call(:set_data_separator, message: message)
  end

  def type
    transport[wsdl].call(:get_value_type, message: { files: resource[:name]})
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
