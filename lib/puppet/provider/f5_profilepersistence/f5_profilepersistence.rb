require 'puppet/provider/f5'

Puppet::Type.type(:f5_profilepersistence).provide(:f5_profilepersistence, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 profilepersistence"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.methods_without_flag
    {
      default_profile: 'defaults',
      description: 'descriptions',
    }
  end

  def self.methods_with_flag
    {
      'across_pool_state'                     => 'states',
      'across_service_state'                  => 'states',
      'across_virtual_state'                  => 'states',
      'cookie_expiration'                     => 'expirations',
      'cookie_hash_length'                    => 'lengths',
      'cookie_hash_offset'                    => 'offsets',
      'cookie_name'                           => 'cookie_names',
      'cookie_persistence_method'             => 'methods',
      'ending_hash_pattern'                   => 'patterns',
      'hash_length'                           => 'lengths',
      'hash_method'                           => 'methods',
      'hash_more_data_state'                  => 'states',
      'hash_offset'                           => 'offsets',
      'map_proxy_address'                     => 'addresses',
      'map_proxy_class'                       => 'classes',
      'map_proxy_state'                       => 'states',
      'mask'                                  => 'masks',
      'maximum_hash_buffer_size'              => 'sizes',
      'mirror_state'                          => 'states',
      'msrdp_without_session_directory_state' => 'states',
      'override_connection_limit_state'       => 'states',
      'persistence_mode'                      => 'modes',
      'rule'                                  => 'rules',
      'sip_info'                              => 'sip_info_headers',
      'starting_hash_pattern'                 => 'patterns',
      'timeout'                               => 'timeouts',
    }
  end

  def self.wsdl
    'LocalLB.ProfilePersistence'
  end
  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get(:get_list).collect do |name|
      new(:name => name, :ensure => :present)
    end
  end

  def self.prefetch(resources)
    profiles = instances
    resources.keys.each do |name|
      if provider = profiles.find { |profile| profile.name == name }
        resources[name].provider = provider
      end
    end
  end

  self.methods_without_flag.each do |method, message_name|
    define_method(method.to_sym) do
      message = { profile_names: { item: resource[:name] }}
      transport[wsdl].get("get_#{method}".to_sym, message)
    end
    define_method("#{method}=") do |value|
      message = { profile_names: { item: resource[:name] }, message_name => { item: resource[method.to_sym] }}
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

  self.methods_with_flag.each do |method, message_name|
    define_method(method.to_sym) do
      message = { profile_names: { item: resource[:name] }}
      response = transport[wsdl].get("get_#{method}".to_sym, message)

      value = response[:value].is_a?(String) ? response[:value] : ''
      # convert to_s so puppet can compare it properly.
      { "value"        => value,
        "default_flag" => response[:default_flag].to_s }
    end
    define_method("#{method}=") do |value|
      message = {
        profile_names: { item: resource[:name] },
        message_name => { item: {
          value: value['value'],
          default_flag: value['default_flag'] }
        },
      }
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

  def create
    # on resource creation ignore default_flag and use persistence_mode value.
    message = {
      profile_names: { item: resource[:name] },
      modes: { item: resource[:persistence_mode]['value'] },
    }
    transport[wsdl].call(:create, message: message)

    self.class.methods_with_flag.each do |method, unused|
      send("#{method}=", resource[method]) if resource[method]
    end
    self.class.methods_without_flag.each do |method, unused|
      send("#{method}=", resource[method]) if resource[method]
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    message = { profile_names: { item: resource[:name] }}
    transport[wsdl].call(:delete_profile, message: message)
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
