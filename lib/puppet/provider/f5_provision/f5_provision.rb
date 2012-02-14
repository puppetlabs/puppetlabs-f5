require 'puppet/provider/f5'

Puppet::Type.type(:f5_provision).provide(:f5_provision, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 provision"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Management.Provision'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [
    'custom_cpu_ratio',
    'custom_disk_ratio',
    'custom_memory_ratio',
    'level'
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        transport[wsdl].send("get_#{method}", [resource[:name]]).first.to_s
      end
    end

    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", [resource[:name]], value)
      end
    end
  end

end
