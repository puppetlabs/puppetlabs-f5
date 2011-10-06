require 'puppet/property/list'
Puppet::Type.newtype(:f5_pool) do
  @doc = "Manage F5 pool."

  apply_to_device

	ensurable do
    desc "Add or delete pool."

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end

  newparam(:name, :namevar=>true) do
    desc "The pool name."
  end

  newproperty(:action_on_service_down) do
    desc "The pool action on service down."
    newvalues(/^SERVICE_DOWN_ACTION_(NONE|RESET|DROP|RESELECT)$/)
  end

  newproperty(:allow_nat_state) do
    desc "The pool allow nat state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:allow_snat_state) do
    desc "The pool allow snat state."
    newvalues(/^STATE_(DISABLED|ENABLED)$/)
  end

  newproperty(:client_ip_tos) do
    desc "The pool client ip tos."
    newvalues(/^\d+$/)
  end

  newproperty(:client_link_qos) do
    desc "The pool client link qos."
    newvalues(/^\d+$/)
  end

  newproperty(:gateway_failsafe_device) do
    desc "The pool gateway failsafe device."
  end

  newproperty(:gateway_failsafe_unit_id) do
    desc "The pool gateway failsafe unit id."
    newvalues(/^\d+$/)
  end

  newproperty(:lb_method) do
    desc "The pool load balancing method."
    newvalues(/^LB_METHOD_(ROUND_ROBIN|RATIO_MEMBER|LEAST_CONNECTION_MEMBER|OBSERVED_MEMBER|PREDICTIVE_MEMBER|RATIO_NODE_ADDRESS|LEAST_CONNECTION_NODE_ADDRESS|FASTEST_NODE_ADDRESS|OBSERVED_NODE_ADDRESS|PREDICTIVE_NODE_ADDESS|DYNAMIC_RATIO|FASTEST_APP_RESPONSE|LEAST_SESSIONS|DYNAMIC_RATIO_MEMBER|L3_ADDR|UNKNOWN|WEIGHTED_LEAST_CONNECTION_MEMBER|WEIGHTED_LEAST_CONNECTION_NODE_ADDRESS|RATIO_SESSION|RATIO_LEAST_CONNECTION_MEMBER|RATIO_LEAST_CONNECTION_NODE_ADDRESS)$/)
  end

  newproperty(:member, :parent => Puppet::Property::List) do
    desc "The pool member."
  end

  newparam(:membership) do
    defaultto :inclusive
  end

  newproperty(:minimum_active_member) do
    desc "The pool minimum active member."
    newvalues(/^\d+$/)
  end

  newproperty(:minimum_up_member) do
    desc "The pool minimum up member."
    newvalues(/^\d+$/)
  end

  newproperty(:minimum_up_member_action) do
    desc "The pool minimum up member action."
  end

  newproperty(:minimum_up_member_enabled_state) do
    desc "The pool minimum up member enabed state."
  end

  newproperty(:monitor_association) do
    desc "The pool monitor association."

    def should_to_s(newvalue)
      newvalue.inspect
    end

    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end

  newproperty(:server_ip_tos) do
    desc "The pool server ip tos."
    newvalues(/^\d+$/)
  end

  newproperty(:server_link_qos) do
    desc "The pool server link qos."
    newvalues(/^\d+$/)
  end

  newproperty(:simple_timeout) do
    desc "The pool simple timeout."
    newvalues(/^\d+$/)
  end

  newproperty(:slow_ramp_time) do
    desc "The pool slow ramp time."
    newvalues(/^\d+$/)
  end
end
