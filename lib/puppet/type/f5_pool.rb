require 'puppet/property/list'

Puppet::Type.newtype(:f5_pool) do
  @doc = "Manage F5 pool."

  apply_to_device
  ensurable

  newparam(:name, :namevar=>true) do
    desc "The pool name."
  end

  newproperty(:action_on_service_down) do
    desc "The action to take when the node goes down for the specified pools."

    newvalues(/^SERVICE_DOWN_ACTION_(NONE|RESET|DROP|RESELECT)$/)
  end

  newproperty(:allow_nat_state) do
    desc "The states indicating whether NATs are allowed for the specified
    pool."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:allow_snat_state) do
    desc "The states indicating whether SNATs are allowed for the specified
    pools."

    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:client_ip_tos) do
    desc "The IP ToS values for client traffic for the specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:client_link_qos) do
    desc "The link QoS values for client traffic for the specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:gateway_failsafe_device) do
    desc "The gateway failsafe devices for the specified pools. (v11.0)"
  end

  newproperty(:lb_method) do
    desc "The load balancing methods for the specified pools."

    newvalues(/^LB_METHOD_(ROUND_ROBIN|RATIO_MEMBER|LEAST_CONNECTION_MEMBER|OBSERVED_MEMBER|PREDICTIVE_MEMBER|RATIO_NODE_ADDRESS|LEAST_CONNECTION_NODE_ADDRESS|FASTEST_NODE_ADDRESS|OBSERVED_NODE_ADDRESS|PREDICTIVE_NODE_ADDESS|DYNAMIC_RATIO|FASTEST_APP_RESPONSE|LEAST_SESSIONS|DYNAMIC_RATIO_MEMBER|L3_ADDR|UNKNOWN|WEIGHTED_LEAST_CONNECTION_MEMBER|WEIGHTED_LEAST_CONNECTION_NODE_ADDRESS|RATIO_SESSION|RATIO_LEAST_CONNECTION_MEMBER|RATIO_LEAST_CONNECTION_NODE_ADDRESS)$/)
  end

  newproperty(:member) do
    desc "The list of pool members."

    def insync?(is)
      # @should is an Array. see lib/puppet/type.rb insync?
      should = @should.first

      # Comparison of hashes
      return false unless is.class == Hash and should.class == Hash and is.keys.sort == should.keys.sort
      should.each do |k, v|
        if v.is_a?(Hash)
          v.each do |l, w|
            # so far all member values are int
            return false unless is[k].include?(l).to_s and is[k][l] == w.to_s
          end
        end
      end
      true
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:minimum_active_member) do
    desc "The minimum active member counts for the specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:minimum_up_member) do
    desc "The minimum member counts that are required to be UP for the
    specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:minimum_up_member_action) do
    desc "The actions to be taken if the minimum number of members required to
    be UP for the specified pools is not met."
  end

  newproperty(:minimum_up_member_enabled_state) do
    desc "The states indicating that the feature that requires a minimum number
    of members to be UP is enabled/disabled for the specified pools."
  end

  newproperty(:monitor_association) do
    desc "The monitor associations for the specified pools, i.e. the monitor
    rules used by the pools. The pool monitor association should be specified
    as a hash consisting of the following keys:
    { 'monitor_templates' => [],
      'quorum' => '0',
      'type' => 'MONITOR_RULE_TYPE_AND_LIST' }"

    munge do |value|
      # Make sure monitor_templates is converted to an array to aid with
      # matching
      value["monitor_templates"] = Array(value["monitor_templates"])
      value
    end

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end

    validate do |value|
      unless value.is_a? Hash then
        raise Puppet::Error.new("Parameter monitor_association failed: must " \
          "be a hash.")
      end

      unless value.size == 3
        raise Puppet::Error.new("Parameter monitor_association failed: there " \
          "should be 3 keys in hash")
      end

      value.keys.each do |key|
        unless ["monitor_templates","quorum","type"].include?(key) then
          raise Puppet::Error.new("Parameter monitor_assocation failed: no " \
            "support for key #{k}")
        end
      end
    end
  end

  newproperty(:server_ip_tos) do
    desc "The IP ToS values for server traffic for the specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:server_link_qos) do
    desc "The link QoS values for server traffic for the specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:simple_timeout) do
    desc "The simple timeouts for the specified pools."

    newvalues(/^\d+$/)
  end

  newproperty(:slow_ramp_time) do
    desc "The ramp-up time (in seconds) to gradually ramp up the load on newly
    added or freshly detected UP pool members."

    newvalues(/^\d+$/)
  end

  autorequire(:f5_monitor) do
    monitors=[]
    if self[:monitor_association] && self[:monitor_association].class == Hash && self[:monitor_association]['monitor_templates'] && self[:monitor_association]['monitor_templates'].class == Array
      self[:monitor_association]['monitor_templates'].each do |m|
        monitors.push(m)
      end
    end
    monitors
  end
end
