require 'f5-icontrol'
require 'util/network_device/f5.rb'

Puppet::Type.type(:f5_snattranslationaddress).provide(:f5_snattranslationaddress, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snattranslationaddress"

  confine :feature => :posix
  defaultfor :feature => :posix

  F5_WSDL = 'LocalLB.SNATTranslationAddress'

  def self.instances
    transport[F5_WSDL].get_list.collect do |name|
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
      if transport[F5_WSDL].respond_to?("get_#{method}".to_sym)
        transport[F5_WSDL].send("get_#{method}", resource[:name]).first
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      if transport[F5_WSDL].respond_to?("set_#{method}".to_sym)
        transport[F5_WSDL].send("set_#{method}", resource[:name], resource[method.to_sym])
      end
    end
  end

  def connection_limit
    val = transport[F5_WSDL].get_connection_limit(resource[:name]).first
    [val.high, val.low]
  end

  def connection_limit=(value)
    val = transport[F5_WSDL].set_connection_limit(resource[:name], resource[:connection_limit])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_SNATTranslationAddress: creating F5 snattranslationaddress #{resource[:name]}")
    transport[F5_WSDL].create(resource[:name])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SNATTranslationAddress: destroying F5 snattranslationaddress #{resource[:name]}")
    transport[F5_WSDL].delete_translation_address(resource[:name])
  end

  def ensure
    transport[F5_WSDL].get_enabled_state(resource[:name])
  end

  def exists?
    transport[F5_WSDL].get_list.include?(resource[:name])
  end
end
