require 'puppet/provider/f5'

Puppet::Type.type(:f5_snattranslationaddress).provide(:f5_snattranslationaddress, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snattranslationaddress"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.SNATTranslationAddress'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'arp_state',
    'enabled_state',
    'ip_timeout',
    'tcp_timeout',
    'udp_timeout',
    'unit_id']

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        transport[wsdl].send("get_#{method}", resource[:name]).first
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", resource[:name], resource[method.to_sym])
      end
    end
  end

  def connection_limit
    val = transport[wsdl].get_connection_limit(resource[:name]).first
    to_64s(val)
  end

  def connection_limit=(value)
    val = transport[wsdl].set_connection_limit(resource[:name], [ to_32h(resource[:connection_limit]) ])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_SNATTranslationAddress: creating F5 snattranslationaddress #{resource[:name]}")
    transport[wsdl].create(resource[:name])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SNATTranslationAddress: destroying F5 snattranslationaddress #{resource[:name]}")
    transport[wsdl].delete_translation_address(resource[:name])
  end

  def ensure
    transport[wsdl].get_enabled_state(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
