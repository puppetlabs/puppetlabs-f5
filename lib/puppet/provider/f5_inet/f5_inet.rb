require 'puppet/provider/f5'

Puppet::Type.type(:f5_inet).provide(:f5_inet, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 inet properties"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'System.Inet'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    [new(:name => transport[wsdl].get_hostname)]
  end
  
  methods = [
    'hostname',
    'ntp_server_address',
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        transport[wsdl].send("get_#{method}").first.to_s
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", resource[method.to_sym])
      end
    end
  end
  
end
