require 'puppet/property/list'
require 'puppet/property/keyvalue'

Puppet::Type.newtype(:f5_monitor) do
  @doc = "Manage F5 monitor."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The monitor name."
  end

  newparam(:is_directly_usable) do
    desc "Determines if the specified monitor templates can be used directly,
    or a user-defined monitor based on each monitor must be created first
    before it can be used."

    defaultto('true')
  end

  newparam(:is_read_only) do
    desc "Determines if the specified monitor templates are read-only. The user
    can only modify properties for read/write monitor templates."

    defaultto('false')
  end

  newproperty(:manual_resume_state) do
    desc "The monitor templates' manual resume states. When enabled and a
    monitor has marked an object down, that object will not be marked up by the
    monitor, i.e. the object will be manually marked up."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newparam(:parent_template) do
    desc "The parent monitor templates from which the specified monitor
    templates are derived. A user-defined monitor template will get its
    defaults from its parent monitor template."

    defaultto('')
  end

  newproperty(:template_destination, :array_matching => :all) do
    desc "The destination IP:port values for the specified templates. NOTE:
    This should only be done when the monitor templates in 'template_names'
    have NOT been associated to any node addresses or pool members."

    defaultto(['ATYPE_STAR_ADDRESS_STAR_PORT', '*:*'])
  end

  newproperty(:template_integer_property) do
    desc "The integer property values of the specified monitor templates."

    munge do |value|
      raise Puppet::Error, "Puppet::Type::F5_Monitor: template_integer_property must be a hash." unless value.is_a? Hash

      value.keys.each do |k|
        unless k =~ /^("|'|)ITYPE_(UNSET|INTERVAL|TIMEOUT|PROBE_(INTERVAL|TIMEOUT|NUM_PROBES|NUM_SUCCESSES)|TIME_UNTIL_UP|UP_INTERVAL)("|'|)$/
          raise Puppet::Error, "Puppet::Type::F5_Monitor: does not support template_integer_property key #{k}"
        end
      end

      # default integer property value to 0 since all resource have all values
      [ 'ITYPE_INTERVAL',
        'ITYPE_PROBE_INTERVAL',
        'ITYPE_PROBE_NUM_SUCCESSES',
        'ITYPE_PROBE_NUM_PROBES',
        'ITYPE_PROBE_TIMEOUT',
        'ITYPE_UNSET',
        'ITYPE_UP_INTERVAL',
        'ITYPE_TIME_UNTIL_UP',
        'ITYPE_TIMEOUT' ].each do |v|

          value[v] = 0 unless value.has_key? v
        end
      value
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end

    defaultto({ 'ITYPE_INTERVAL' => 5,
                'ITYPE_TIMEOUT'  => 16 })
  end

  newproperty(:template_state) do
    desc "The monitor templates' enabled/disabled states. This will
    enable/disable all instances that use the specified templates. This serves
    as a quick and convenient method to enable/disable all instances, but if
    you want only to enable/disable a specific instance, use
    set_instance_enabled."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:template_string_property) do
    desc "The string property values of the specified monitor templates."

    munge do |value|
      raise Puppet::Error, "Puppet::Type::F5_Monitor: template_integer_property must be a hash." unless value.is_a? Hash

      value.keys.each do |k|
        unless k =~ /^("|'|)STYPE_(UNSET|SEND|GET|RECEIVE|USERNAME|PASSWORD|RUN|NEWSGROUP|DATABASE|DOMAIN|ARGUMENTS|FOLDER|BASE|FILTER|SECRET|METHOD|URL|COMMAND|METRICS|POST|USERAGENT|AGENT_TYPE|(CPU|MEMORY|DISK)_(COEFFICIENT|THRESHOLD)|SNMP_VERSION|COMMUNITY|(SEND|TIMEOUT)_PACKETS|RECEIVE_(DRAIN|ROW|COLUMN)|DEBUG|SECURITY|MODE|CIPHER_LIST|NAMESPACE|PARAMETER_(NAME|VALUE|TYPE)|RETURN_(TYPE|VALUE)|SOAP_FAULT|SSL_OPTIONS|CLIENT_CERTIFICATE|PROTOCOL|MANDATORY_ATTRS|FILENAME|ACCOUNTING_(NODE|PORT)|(SERVER|CALL|SESSION)_ID|FRAMED_ADDRESS|PROGRAM|VERSION|SERVER|SERVICE|GW_MONITOR_(ADDRESS|SERVICE|INTERVAL|PROTOCOL)|DB_COUNT|REQUEST|HEADERS|FILTER_NEG|SERVER_IP|SNMP_PORT|POOL_NAME|NAS_IP|CLIENT_KEY|MAX_LOAD_AVERAGE|CONCURRENCY_LIMIT|FAILURES|FAILURE_INTERVAL|(RESPONSE|RETRY)_TIME|DIAMETER_((ACCT|AUTH)_APPLICATION_ID|ORIGIN_(HOST|REALM)|HOST_IP_ADDRESS|VENDOR_ID|PRODUCT_NAME|VENDOR_SPECIFIC_(VENDOR_ID|(ACCT|AUTH)_APPLICATION_ID))|RUN_V2|CLIENT_(CERTIFICATE_V2|KEY_V2))("|'|)$/
          raise Puppet::Error, "Puppet::Type::F5_Monitor: does not support template_string_property key #{k}"
        end
      end
      # Filter out any blank strings.
      value.select {|key, contents| contents != ''}
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:template_type) do
    desc "The template types of the specified monitor templates."

    newvalues(/^TTYPE_(UNSET|ICMP|TCP|TCP_ECHO|EXTERNAL|HTTP|HTTPS|NNTP|FTP|POP3|SMTP|MSSQL|GATEWAY|IMAP|RADIUS|LDAP|WMI|SNMP_DCA(|_BASE)|REAL_SERVER|UDP|NONE|ORACLE|SOAP|GATEWAY_ICMP|SIP|TCP_HALF_OPEN|SCRIPTED|WAP|RPC|SMB|SASP|MODULE_SCORE|FIREPASS|INBAND|RADIUS_ACCOUNTING|DIAMETER|VIRTUAL_LOCATION|MYSQL|POSTGRESQL)$/)
  end

  newproperty(:template_transparent_mode) do
    desc "The monitor template transparent mode."

    newvalues(:true, :false)
  end
end
