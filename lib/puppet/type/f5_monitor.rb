require 'puppet/property/list'
require 'puppet/property/keyvalue'

Puppet::Type.newtype(:f5_monitor) do
  @doc = "Manage F5 monitor."

  apply_to_device

	ensurable do
    desc "Add or delete monitor."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The monitor name."
  end

  newproperty(:manual_resume_state) do
    desc "The monitor allow nat state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newparam(:parent_template) do
    desc "The parent template name."
  end

  newproperty(:template_destination) do
    desc "The template destination."
  end

  newproperty(:template_integer_property) do
    desc "The template integer property."
    newvalues(/^ITYPE_(UNSET|INTERVAL|TIMEOUT|PROBE_(INTERVAL|TIMEOUT|NUM_PROBES|NUM_SUCCESSES)|TIME_UTIL_UP|UP_INTERVAL)$/)

    def should_to_s(newvalue)
      Puppet.debug("calling should_to_s")
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:template_state) do
    desc "The template state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:template_string_property) do
    desc "The template string property."
    newvalues(/^STYPE_(UNSET|SEND|GET|RECIEVE|USERNAME|PASSWORD|RUN|NEWSGROUP|DATABASE|DOMAIN|AUGUMENTS|FOLDER|BASE|FILTER|SECRET|METHOD|URL|COMMAND|METRICS|POST|USERAGENT|AGENT_TYPE|(CPU|MEMORY|DISK)_(COEFFICIENT|THRESHOLD)|SNMP_VERSION|COMMUNITY|(SEND|TIMEOUT)_PACKETS|RECIEVE_(DRAIN|ROW|COLUMN)|DEBUG|SECURITY|MODE|CIPHER_LIST|NAMESPACE|PARAMETER_(NAME|VALUE|TYPE)|RETURN_(TYPE|VALUE)|SOAP_FAULT|SSL_OPTIONS|CLIENT_CERTIFICATE|PROTOCOL|MANDATORY_ATTRS|FILENAME|ACCOUNTING_(NODE|PORT)|(SERVER|CALL|SESSION)_ID|FRAMED_ADDRESS|PROGRAM|VERSION|SERVER|SERVICE|GW_MONITOR_(ADDRESS|SERVICE|INTERVAL|PROTOCOL)|DB_COUNT|REQUEST|HEADERS|FILTER_NEG|SERVER_IP|SNMP_PORT|POOL_NAME|NAS_IP|CLIENT_KEY|MAX_LOAD_AVERAGE|CONCURRENCY_LIMIT|FAILURES|FAILURE_INTERVAL|(RESPONSE|RETRY)_TIME|DIAMETER_((ACCT|AUTH)_APPLICATION_ID|ORIGIN_(HOST|REALM)|HOST_IP_ADDRESS|VENDOR_ID|PRODUCT_NAME|VENDOR_SPECIFIC_(VENDOR_ID|ACCT_APPLICATION_ID))|RUN_V2|CLIENT_(CERTIFICATE_V2|KEY_V2))$/)
  end

  newproperty(:template_transparent_mode) do
    desc "The monitor gateway failsafe unit id."
  end

  #newproperty(:template_user_defined_string_property) do
  #  desc "The monitor load balancing method."
  #end
end
