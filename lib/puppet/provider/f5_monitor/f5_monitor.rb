require 'puppet/provider/f5'

Puppet::Type.type(:f5_monitor).provide(:f5_monitor, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 monitor"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.Monitor'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_template_list.collect do |monitor_template|
      new(:name => monitor_template.template_name,
          :ensure => :present,
          :type => monitor_template.template_type)
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def flush
    @property_hash.clear
  end

  methods = [ 'manual_resume_state',
              'parent_template',
              'template_state',
              'template_transparent_mode',
              'template_user_defined_string_property']

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

  def template_destination
    destinations= transport[wsdl].get_template_destination(resource[:name])
    destinations = destinations.collect { |system|
      # need F5 eng review: http://devcentral.f5.com/wiki/iControl.LocalLB__AddressType.ashx
      #Puppet.debug("Puppet::Provider::F5_monitor: template destination address type #{system.address_type} address #{system.ipport.address} port #{system.ipport.port}")
      case system.address_type
      when 'ATYPE_STAR_ADDRESS_STAR_PORT'
        "*:*"
      when 'ATYPE_STAR_ADDRESS_EXPLICIT_PORT'
        "*:#{system.ipport.port}"
      when 'ATYPE_EXPLICIT_ADDRESS_EXPLICIT_PORT'
        "#{system.ipport.address}:#{system.ipport.port}"
      when 'ATYPE_STAR_ADDRESS'
        "*:*"
      when 'ATYPE_EXPLICIT_ADDRESS'
        "#{system.ipport.address}:*"
      else
        "#{system.ipport.address}:#{system.ipport.port}"
      end
    }.sort.join(',')
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
      template_integer[property] = transport[wsdl].get_template_integer_property(resource[:name],property).first.value
    end
    template_integer
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
        template_string[property] = transport[wsdl].get_template_string_property(resource[:name],property).first.value
      rescue Exception => e
        # Not all string property are supported for every resource, so ignoring failures. Disable debug since it's too much noise.
        #Puppet.debug("Puppet::Provider::F5_Monitor: ignoring get_template_string_property exception \n #{e.message}")
      end
    end
    template_string
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
