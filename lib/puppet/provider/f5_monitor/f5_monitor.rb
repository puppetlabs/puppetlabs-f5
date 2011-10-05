require 'puppet/provider/f5'

Puppet::Type.type(:f5_monitor).provide(:f5_monitor, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 monitor"

  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.wsdl
    'LocalLB.Monitor'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    f5monitors = Array.new
    monitor = Hash.new

    transport[wsdl].get_template_list.collect do |monitor_template|
      monitor = { :name => monitor_template.template_name,
                  :ensure => :present,
                  :type => monitor_template.template_type }
      f5monitors << new(monitor)
    end
    f5monitors
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    @property_hash[:name] ||= resource[:name]
  end

  methods = [ 'manual_resume_state',
              'parent_template',
              'template_state',
              'template_transparent_mode',
              'template_user_defined_string_property']

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        transport[wsdl].send("get_#{method}", @property_hash[:name]).first.to_s
      end
    end
  end

  methods.each do |method|
    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", @property_hash[:name], resource[method.to_sym])
      end
    end
  end

  def monitor_ipport(value)
    # change ip/port to a hash F5 create_template accepts, process wildcards to 0.0.0.0:0 as appropriate.
    address_type = value[0]
    address      = network_address(value[1])
    port         = network_port(value[1])

    address = '0.0.0.0' if address == '*'
    port    = 0         if port == '*'

    {:address_type => address_type, :ipport => {:address => address, :port => port}}
  end

  def template_destination
    destinations= transport[wsdl].get_template_destination(resource[:name])
    system = destinations.first
    # need F5 eng review: http://devcentral.f5.com/wiki/iControl.LocalLB__AddressType.ashx
    #Puppet.debug("Puppet::Provider::F5_monitor: template destination address type #{system.address_type} address #{system.ipport.address} port #{system.ipport.port}")
    case system.address_type
    when 'ATYPE_STAR_ADDRESS_STAR_PORT'
      [ 'ATYPE_STAR_ADDRESS_STAR_PORT', "*:*" ]
    when 'ATYPE_STAR_ADDRESS_EXPLICIT_PORT'
      [ 'ATYPE_STAR_ADDRESS_EXPLICIT_PORT', "*:#[system.ipport.port}" ]
    when 'ATYPE_EXPLICIT_ADDRESS_EXPLICIT_PORT'
      [ 'ATYPE_EXPLICIT_ADDRESS_EXPLICIT_PORT', "#[system.ipport.address}:#[system.ipport.port}" ]
    when 'ATYPE_STAR_ADDRESS'
      [ 'ATYPE_STAR_ADDRESS', "*:*" ]
    when 'ATYPE_EXPLICIT_ADDRESS'
      [ 'ATYPE_EXPLICIT_ADDRESS', "#[system.ipport.address}:*" ]
    else
      [ 'ATYPE_UNSET', "#[system.ipport.address}:#[system.ipport.port}" ]
    end
  end

  def template_destination=(value)
    transport[wsdl].set_template_destination(monitor_ipport(resource[:template_destination]))
  end

  def template_integer_property
    properties = [ 'ITYPE_UNSET',
                   'ITYPE_INTERVAL',
                   'ITYPE_TIMEOUT',
                   'ITYPE_PROBE_INTERVAL',
                   'ITYPE_PROBE_TIMEOUT',
                   'ITYPE_PROBE_NUM_PROBES',
                   'ITYPE_PROBE_NUM_SUCCESSES',
                   'ITYPE_TIME_UNTIL_UP',
                   'ITYPE_UP_INTERVAL']

    template_integer = {}
    properties.each do |property|
      template_integer[property] = transport[wsdl].get_template_integer_property(@property_hash[:name],property).first.value
    end
    template_integer
  end

  def template_integer_property=(value)
    resource[:template_integer_property].each do |k, v|
      # Trying to configure ITYPE_UNSET results in Exception: Common::OperationFailed
      transport[wsdl].set_template_integer_property(resource[:name], [{:type => k, :value => v}]) unless k = 'ITYPE_UNSET'
    end
    true
  end

  def template_string_property
    properties = [ 'STYPE_UNSET',
                   'STYPE_SEND',
                   'STYPE_GET',
                   'STYPE_RECEIVE',
                   'STYPE_USERNAME',
                   'STYPE_PASSWORD',
                   'STYPE_RUN',
                   'STYPE_NEWSGROUP',
                   'STYPE_DATABASE',
                   'STYPE_DOMAIN',
                   'STYPE_ARGUMENTS',
                   'STYPE_FOLDER',
                   'STYPE_BASE',
                   'STYPE_FILTER',
                   'STYPE_SECRET',
                   'STYPE_METHOD',
                   'STYPE_URL',
                   'STYPE_COMMAND',
                   'STYPE_METRICS',
                   'STYPE_POST',
                   'STYPE_USERAGENT',
                   'STYPE_AGENT_TYPE',
                   'STYPE_CPU_COEFFICIENT',
                   'STYPE_CPU_THRESHOLD',
                   'STYPE_MEMORY_COEFFICIENT',
                   'STYPE_MEMORY_THRESHOLD',
                   'STYPE_DISK_COEFFICIENT',
                   'STYPE_DISK_THRESHOLD',
                   'STYPE_SNMP_VERSION',
                   'STYPE_COMMUNITY',
                   'STYPE_SEND_PACKETS',
                   'STYPE_TIMEOUT_PACKETS',
                   'STYPE_RECEIVE_DRAIN',
                   'STYPE_RECEIVE_ROW',
                   'STYPE_RECEIVE_COLUMN',
                   'STYPE_DEBUG',
                   'STYPE_SECURITY',
                   'STYPE_MODE',
                   'STYPE_CIPHER_LIST',
                   'STYPE_NAMESPACE',
                   'STYPE_PARAMETER_NAME',
                   'STYPE_PARAMETER_VALUE',
                   'STYPE_PARAMETER_TYPE',
                   'STYPE_RETURN_TYPE',
                   'STYPE_RETURN_VALUE',
                   'STYPE_SOAP_FAULT',
                   'STYPE_SSL_OPTIONS',
                   'STYPE_CLIENT_CERTIFICATE',
                   'STYPE_PROTOCOL',
                   'STYPE_MANDATORY_ATTRS',
                   'STYPE_FILENAME',
                   'STYPE_ACCOUNTING_NODE',
                   'STYPE_ACCOUNTING_PORT',
                   'STYPE_SERVER_ID',
                   'STYPE_CALL_ID',
                   'STYPE_SESSION_ID',
                   'STYPE_FRAMED_ADDRESS',
                   'STYPE_PROGRAM',
                   'STYPE_VERSION',
                   'STYPE_SERVER',
                   'STYPE_SERVICE',
                   'STYPE_GW_MONITOR_ADDRESS',
                   'STYPE_GW_MONITOR_SERVICE',
                   'STYPE_GW_MONITOR_INTERVAL',
                   'STYPE_GW_MONITOR_PROTOCOL',
                   'STYPE_DB_COUNT',
                   'STYPE_REQUEST',
                   'STYPE_HEADERS',
                   'STYPE_FILTER_NEG',
                   'STYPE_SERVER_IP',
                   'STYPE_SNMP_PORT',
                   'STYPE_POOL_NAME',
                   'STYPE_NAS_IP',
                   'STYPE_CLIENT_KEY',
                   'STYPE_MAX_LOAD_AVERAGE',
                   'STYPE_CONCURRENCY_LIMIT',
                   'STYPE_FAILURES',
                   'STYPE_FAILURE_INTERVAL',
                   'STYPE_RESPONSE_TIME',
                   'STYPE_RETRY_TIME',
                   'STYPE_DIAMETER_ACCT_APPLICATION_ID',
                   'STYPE_DIAMETER_AUTH_APPLICATION_ID',
                   'STYPE_DIAMETER_ORIGIN_HOST',
                   'STYPE_DIAMETER_ORIGIN_REALM',
                   'STYPE_DIAMETER_HOST_IP_ADDRESS',
                   'STYPE_DIAMETER_VENDOR_ID',
                   'STYPE_DIAMETER_PRODUCT_NAME',
                   'STYPE_DIAMETER_VENDOR_SPECIFIC_VENDOR_ID',
                   'STYPE_DIAMETER_VENDOR_SPECIFIC_ACCT_APPLICATION_ID',
                   'STYPE_DIAMETER_VENDOR_SPECIFIC_AUTH_APPLICATION_ID',
                   'STYPE_RUN_V2',
                   'STYPE_CLIENT_CERTIFICATE_V2',
                   'STYPE_CLIENT_KEY_V2' ]

    template_string = {}
    properties.each do |property|
      begin
        template_string[property] = transport[wsdl].get_template_string_property(@property_hash[:name],property).first.value
      rescue Exception => e
        # Not all string property are supported for every template type, so we are ignoring all failures.
        # Disable debug message since it's too much noise.
        #Puppet.debug("Puppet::Provider::F5_Monitor: ignoring get_template_string_property exception \n #{e.message}")
      end
    end
    template_string
  end

  def template_string_property=(value)
    resource[:template_string_property].each do |k, v|
      transport[wsdl].set_template_string_property(resource[:name], [{:type => k, :value => v}])
    end
  end

  def template_type
    transport[wsdl].get_template_type(@property_hash[:name]).first
  end

  def template_type=(value)
    # can't alter template_type, so destroy and recreate resource.
    destroy
    create
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Monitor: creating F5 monitor #{resource[:name]}")

    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end

    monitor_template = { :template_name => resource[:name],
                         :template_type => resource[:template_type] }

    # configure timeout default based on F5 recommendation of 3x interval + 1 second.
    # http://devcentral.f5.com/wiki/iControl.LocalLB__Monitor__CommonAttributes.ashx
    if resource[:template_integer_property] then
      interval = resource[:template_integer_property]['ITYPE_INTERVAL']
      timeout  = resource[:template_integer_property]['ITYPE_TIMEOUT']
    end
    interval ||= 5
    timeout  ||= 3 * interval + 1

    common_attributes = { :parent_template    => resource[:parent_template],
                          :interval           => interval,
                          :timeout            => timeout,
                          :dest_ipport        => monitor_ipport(resource[:template_destination]),
                          :is_read_only       => resource[:is_read_only],
                          :is_directly_usable => resource[:is_directly_usable] }

    transport[wsdl].create_template([monitor_template], [common_attributes])

    # Update integer and string property upon resource creation
    self.template_integer_property=resource[:template_integer_property] if resource[:template_integer_property]
    self.template_string_property=resource[:template_string_property] if resource[:template_string_property]
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Monitor: deleting F5 monitor #{resource[:name]}")
    @property_hash[:ensure] = :absent
    transport[wsdl].delete_template(@property_hash[:name])
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
