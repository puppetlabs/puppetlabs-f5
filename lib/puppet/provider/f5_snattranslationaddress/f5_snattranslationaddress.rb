require 'puppet/provider/f5'

Puppet::Type.type(:f5_snattranslationaddress).provide(:f5_snattranslationaddress, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snattranslationaddress"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.SNATTranslationAddressV2'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    Array(transport[wsdl].get(:get_list)).collect do |item|
      new(:name => item)
    end
  end

  methods = {
    'arp_state'         => 'states',
    'connection_limit'  => 'limits',
    'enabled_state'     => 'states',
    'ip_timeout'        => 'timeouts',
    'tcp_timeout'       => 'timeouts',
    'udp_timeout'       => 'timeouts'
  }

  methods.each do |method, arg|
    define_method(method.to_sym) do
      transport[wsdl].get("get_#{method}".to_sym, { translation_addresses: { item: resource[:name] } })
    end
    define_method("#{method}=") do |value|
      message = { translation_addresses: { item: resource[:name] }, arg => { item: resource[method.to_sym] } }
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_SNATTranslationAddress: creating F5 snattranslationaddress #{resource[:name]}")
    message = {
      translation_addresses: { item: resource[:name] },
      addresses: { item: resource[:addresses] },
      traffic_groups: { item: '' }
    }
    transport[wsdl].call(:create, message: message)

    methods = [
      'arp_state',
      'enabled_state',
      'ip_timeout',
      'tcp_timeout',
      'udp_timeout'
    ]

    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SNATTranslationAddress: destroying F5 snattranslationaddress #{resource[:name]}")
    message = { translation_addresses: { item: resource[:name] } }
    transport[wsdl].call(:delete_translation_address, message: message)
  end

  def exists?
    transport[wsdl].get(:get_list).include?(resource[:name])
  end
end
