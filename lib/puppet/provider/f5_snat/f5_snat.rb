require 'puppet/provider/f5'

Puppet::Type.type(:f5_snat).provide(:f5_snat, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snat"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.SNAT'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'connection_mirror_state',
    'description',
    'source_port_behavior',
    'vlan']

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

  def original_address
    val = transport[wsdl].get_original_address(resource[:name]).first
    [val.first.original_address, val.first.wildmask]
  end

  def translation_target
    val = transport[wsdl].get_translation_target(resource[:name]).first
    [val.type, val.translation_object]
  end

  def translation_target=(value)
    transport[wsdl].set_translation_target(resource[:name], resource[:translation_target])
  end

  def vlan
    val = transport[wsdl].get_vlan(resource[:name]).first
    [val.state, val.vlans]
  end

  def vlan=(value)
    transport[wsdl].set_vlan(resource[:name], resource[:vlan])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Snat: creating F5 snat #{resource[:name]}")
    resource[:original_address] ||= ['0.0.0.0', '0.0.0.0']
    resource[:vlan] ||= ['STATE_DISABLED', '']

    transport[wsdl].create([resource[:name], resource[:translation_target]],
                           resource[:original_address],
                           resource[:vlan])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Snat: destroying F5 snat #{resource[:name]}")
    transport[wsdl].delete_snat(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
