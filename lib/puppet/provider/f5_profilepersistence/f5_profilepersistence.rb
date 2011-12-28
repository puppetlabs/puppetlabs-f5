require 'puppet/provider/f5'

Puppet::Type.type(:f5_profilepersistence).provide(:f5_profilepersistence, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 profilepersistence"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.ProfilePersistence'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  # these two methods don't support default_flag
  methods = [
    'default_profile',
    'description',
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        profile = transport[wsdl].send("get_#{method}", resource[:name]).first
        profile
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

  methods = [
    'across_pool_state',
    'across_service_state',
    'across_virtual_state',
    'cookie_expiration',
    'cookie_hash_length',
    'cookie_hash_offset',
    'cookie_name',
    'cookie_persistence_method',
    'ending_hash_pattern',
    'hash_length',
    'hash_method',
    'hash_more_data_state',
    'hash_offset',
    'map_proxy_address',
    'map_proxy_class',
    'map_proxy_state',
    'mask',
    'maximum_hash_buffer_size',
    'mirror_state',
    'msrdp_without_session_directory_state',
    'override_connection_limit_state',
    'persistence_mode',
    'rule',
    'sip_info',
    'starting_hash_pattern',
    'timeout',
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        profile_string = transport[wsdl].send("get_#{method}", resource[:name]).first

        # convert to_s so puppet can compare it properly.
        { "value"        => profile_string.value.to_s,
          "default_flag" => profile_string.default_flag}
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", resource[:name],
                              [ :value        => value["value"],
                                :default_flag => value["default_flag"] ])
      end
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_ProfilePersistence: creating F5 persistence profile #{resource[:name]}")

    # on resource creation ignore default_flag and use persistence_mode value.
    transport[wsdl].create([resource[:name]], [resource[:persistence_mode]['value']])

    methods = [
      'across_pool_state',
      'across_service_state',
      'across_virtual_state',
      'cookie_expiration',
      'cookie_hash_length',
      'cookie_hash_offset',
      'cookie_name',
      'cookie_persistence_method',
      'ending_hash_pattern',
      'hash_length',
      'hash_method',
      'hash_more_data_state',
      'hash_offset',
      'map_proxy_address',
      'map_proxy_class',
      'map_proxy_state',
      'mask',
      'maximum_hash_buffer_size',
      'mirror_state',
      'msrdp_without_session_directory_state',
      'override_connection_limit_state',
      'rule',
      'sip_info',
      'starting_hash_pattern',
      'timeout',
    ]

    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_ProfilePersistence: destroying F5 persistence profile #{resource[:name]}")
    transport[wsdl].delete_profile([resource[:name]])
  end

  def exists?
    #require 'ruby-debug'
    #Debugger.start
    #debugger
    transport[wsdl].get_list.include?(resource[:name])
  end
end
