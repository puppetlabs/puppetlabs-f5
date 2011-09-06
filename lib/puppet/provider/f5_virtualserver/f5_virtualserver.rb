require 'puppet/provider/f5'

Puppet::Type.type(:f5_virtualserver).provide(:f5_virtualserver, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 device"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.VirtualServer'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'actual_hardware_acceleration',
    'cmp_enable_mode',
    'cmp_enabled_state',
    # 'connection_limit',
    'connection_mirror_state',
    'default_pool_name',
    'enabled_state',
    'fallback_persistence_profile',
    # 'gtm_score',
    'last_hop_pool',
    'nat64_state',
    'protocol',
    'rate_class',
    'snat_automap',
    'snat_none',
    'snat_pool',
    'source_port_behavior',
    'translate_address_state',
    'translate_port_state',
    'type',
    'vlan',
    'wildmask']

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
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

  def connection_limit
    val = transport[wsdl].get_connection_limit(resource[:name]).first
    [val.high, val.low]
  end

  def connection_limit=(value)
    transport[wsdl].set_connection_limit(resource[:name], resource[:connection_limit])
  end

  def gtm_score
    val = transport[wsdl].get_gtm_score(resource[:name]).first
    [val.high, val.low]
  end

  def gtm_score=(value)
    transport[wsdl].set_gtm_score(resource[:name], resource[:gtm_score])
  end

  def destination
    destination = transport[wsdl].get_destination(resource[:name])

    destination = destination.collect { |system|
      "#{system.address}:#{system.port}"
    }.sort.join(',')
  end

  def destination=
    transport[wsdl].set_destination(resource[:name],
      [[{:address => fetch_address(resource[:destination]),
         :port    => fetch_port(resource[:destination])}]])
  end

  def fetch_address(dest)
    dest.split(':')[0]
  end

  def fetch_port(dest)
    dest.split(':')[1]
  end

  def create
    Puppet.debug("Puppet::Provider::F5_VirtualServer: creating F5 virtual server #{resource[:name]}")

    vs_definition = [{"name" => resource[:name],
                      "address" => fetch_address(resource[:destination]),
                      "port" => fetch_port(resource[:destination]).to_i,
                      "protocol" => resource[:protocol]}]
    vs_wildmask = resource[:wildmask]
    vs_resources = [{"type" => resource[:type]}]
    vs_profiles = [[]]

    transport[wsdl].create(vs_definition, vs_wildmask, vs_resources, vs_profiles)

    if resource[:default_pool_name]
      self.default_pool_name = resource[:default_pool_name]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying F5 virtual server #{resource[:name]}")
    transport[wsdl].delete_virtual_server(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
