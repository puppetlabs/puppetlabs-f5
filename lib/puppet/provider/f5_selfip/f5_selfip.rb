require 'puppet/provider/f5'

Puppet::Type.type(:f5_selfip).provide(:f5_selfip_v9, :parent => Puppet::Provider::F5) do
  @doc = "Manages F5 selfip"

  bigip_version = /([\d\.]+)$/.match(facts["version"])
  confine    :feature => :posix
  confine    :true    => if Gem::Version.new(bigip_version) < Gem::Version.new('11.0.0')
    true
  end
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.SelfIP'
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
    'floating_state',
    'netmask',
    'unit_id',
    'vlan'
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        Puppet.debug("Puppet::Provider::F5_SelfIP: retrieving #{method} for #{resource[:name]}")
        transport[wsdl].send("get_#{method}", resource[:name]).first.to_s
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

  def create
    Puppet.debug("Puppet::Provider::F5_SelfIP: creating F5 self IP #{resource[:name]}")
    transport[wsdl].create([resource[:name]],[resource[:vlan]],[resource[:netmask]],[resource[:unit_id]],[resource[:floating_state]])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SelfIP: destroying F5 self IP #{resource[:name]}")
    transport[wsdl].delete_self_ip(resource[:name])
  end

  def exists?
    r=transport[wsdl].get_list.include?(resource[:name])
    Puppet.debug("Puppet::Provider::F5_SelfIP: does F5 self IP #{resource[:name]} exist ? #{r}")
    r
  end
end
