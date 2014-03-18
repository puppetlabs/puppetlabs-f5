Puppet::Type.newtype(:f5_profilepersistence) do
  @doc = "Manage F5 Client SSL profiles."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The persistence profile name."
  end

  newproperty(:across_pool_state) do
    desc "The states to indicate whether persistence entries added under this
    profile are available across pools. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: across_pool_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:across_service_state) do
    desc "The states to indicate whether persistence entries added under this
    profile are available across services. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: across_service_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:across_virtual_state) do
    desc "The states to indicate whether persistence entries added under this
    profile are available across virtuals. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: across_virtual_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:cookie_expiration) do
    desc "The cookie expiration in seconds for the specified Persistence
    profiles. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE.
    (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: cookie_expiration value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:cookie_hash_length) do
    desc "The cookie hash lengths for the specified profiles. Applicable when
    peristence mode is PERSISTENCE_MODE_COOKIE, and cookie persistence method
    is COOKIE_PERSISTENCE_METHOD_HASH. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: cookie_hash_length value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end
  end

  newproperty(:cookie_hash_offset) do
    desc "The cookie hash offsets for the specified profiles. Applicable when
    peristence mode is PERSISTENCE_MODE_COOKIE, and cookie persistence method
    is COOKIE_PERSISTENCE_METHOD_HASH. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: cookie_hash_offset value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end
  end

  newproperty(:cookie_name) do
    desc "The cookie names for the specified Persistence profiles. Applicable
    when peristence mode is PERSISTENCE_MODE_COOKIE. (v9.0)"

    #validate do |value|
    #  raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: cookie_name value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    #end
  end

  newproperty(:cookie_persistence_method) do
    desc "The cookie persistence methods to be used when in cookie persistence
    mode. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: cookie_persistence_method value must be /^COOKIE_PERSISTENCE_METHOD_(NONE|INSERT|REWRITE|PASSIVE|HASH)$/.' unless value['value'] =~ /^COOKIE_PERSISTENCE_METHOD_(NONE|INSERT|REWRITE|PASSIVE|HASH)$/
    end
  end

  newproperty(:default_profile) do
    desc "The names of the default profiles from which the specified profiles
    will derive default values for its attributes. (v9.0)"
  end

  newproperty(:description) do
    desc "The descriptions for a set of persistence profiles. (v11.0)"
  end

  newproperty(:ending_hash_pattern) do
    desc "the pattern marking the end of the section of payload data whose
    hashed value is used for the persistence value for a set of persistence
    profiles. This only returns useful values if the persistence mode is
    PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.
      (v10.1)"
  end

  newproperty(:hash_length) do
    desc "The length of payload data whose hashed value is used for the
    persistence value for a set of persistence profiles. This only returns
    useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash
    method is PERSISTENCE_HASH_CARP. (v10.1)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: hash_length value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end
  end

  newproperty(:hash_method) do
    desc "The hash method used to generate the persistence values for a set of
    persistence profiles. This only returns useful values if the persistence
    mode is PERSISTENCE_MODE_HASH. (v10.1)"
  end

  newproperty(:hash_more_data_state) do
    desc "The enabled state whether to perform another hash operation after the
    current hash operation completes for a set of persistence profiles. This
    only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH
    and the hash method is PERSISTENCE_HASH_CARP. (v10.1)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: hash_more_data_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:hash_offset) do
    desc "The offset to the start of the payload data whose hashed value is
    used as the persistence value for a set of persistence profiles. This only
    returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and
    the hash method is PERSISTENCE_HASH_CARP. (v10.1)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: hash_offset value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end
  end

  newproperty(:map_proxy_address) do
    desc "The proxy map address used when map proxies state is enabled on
    source address persistence mode. (v11.0)"
  end

  newproperty(:map_proxy_class) do
    desc "The proxy map IP address class/datagroup name used when map known
    proxies state is enabled on source address persistence mode. (v11.0)"
  end

  newproperty(:map_proxy_state) do
    desc "The states to indicate whether to map known proxies when the
    persistence mode is source address affinity. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: map_proxy_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:mask) do
    desc "The masks used in either simple or sticky persistence mode. (v9.0)"
  end

  newproperty(:maximum_hash_buffer_size) do
    desc "The maximum size of the buffer used to hold the section of the
    payload data whose hashed value is used for the persistence value for a set
    of persistence values. This only returns useful values if the persistence
    mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.
      (v10.1)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: maximum_hash_buffer_size value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end
  end

  newproperty(:mirror_state) do
    desc "The mirror states for the specified Persistence profiles. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: mirror_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:msrdp_without_session_directory_state) do
    desc "The states to indicate whether MS terminal services have been
    configured without a session directory for the specified Persistence
    profiles. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: msrdp_without_session_directory_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:override_connection_limit_state) do
    desc "The state indicating, when enabled, that the pool member connection
    limits are not enforced for persisted clients. (v11.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: override_connection_limite_state value must be /^STATE_(DISABLED|ENABLED)$/.' unless value['value'] =~ /^STATE_(DISABLED|ENABLED)$/
    end
  end

  newproperty(:persistence_mode) do
    desc "The persistence modes for the specified Persistence profiles. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: persistence_mode value must be /^PERSISTENCE_MODE_(NONE|SOURCE_ADDRESS_AFFINITY|DESTINATION_ADDRESS_AFFINITY|COOKIE|MSRDP|SSL_SID|SIP|UIE|HASH)$/.' unless value['value'] =~ /^PERSISTENCE_MODE_(NONE|SOURCE_ADDRESS_AFFINITY|DESTINATION_ADDRESS_AFFINITY|COOKIE|MSRDP|SSL_SID|SIP|UIE|HASH)$/
    end
  end

  newproperty(:rule) do
    desc "The UIE rules for the specified Persistence profiles. Applicable when
    peristence mode is PERSISTENCE_MODE_UIE. (v9.0)"
  end

  newproperty(:sip_info) do
    desc "The sip_info headers for the specified Persistence profiles.
    Applicable when peristence mode is PERSISTENCE_MODE_SIP. (v9.4.2)"
  end

  newproperty(:starting_hash_pattern) do
    desc "The pattern marking the start of the section of payload data whose hashed value is used for the persistence value for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP. (v10.1)"
  end

  newproperty(:timeout) do
    desc "The timeout for the specified Persistence profiles. The number of
    seconds to timeout a persistence entry. (v9.0)"

    validate do |value|
      raise Puppet::Error, 'Pupppet::Type::F5_ProfilePersistence: timeout value must be /^\d+$/.' unless value['value'] =~ /^\d+$/
    end
  end
end
