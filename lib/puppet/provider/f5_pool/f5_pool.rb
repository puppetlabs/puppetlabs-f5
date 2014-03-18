require 'puppet/provider/f5'

Puppet::Type.type(:f5_pool).provide(:f5_pool, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 pool"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.Pool'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    Array(transport[wsdl].get(:get_list)).collect do |name|
      new(:name => name)
    end
  end

  methods = {
    'action_on_service_down'          => 'actions',
    'allow_nat_state'                 => 'states',
    'allow_snat_state'                => 'states',
    'client_ip_tos'                   => 'values',
    'client_link_qos'                 => 'values',
    'gateway_failsafe_device'         => 'devices',
    'lb_method'                       => 'lb_methods',
    'minimum_active_member'           => 'values',
    'minimum_up_member'               => 'values',
    'minimum_up_member_action'        => 'actions',
    'minimum_up_member_enabled_state' => 'states',
    'server_ip_tos'                   => 'values',
    'server_link_qos'                 => 'values',
    'simple_timeout'                  => 'simple_timeouts',
    'slow_ramp_time'                  => 'values'
  }

  methods.each do |method, message|
    define_method(method.to_sym) do
      transport[wsdl].get("get_#{method}".to_sym, { pool_names: { item: resource[:name] }})
    end
    define_method("#{method}=") do |value|
      message = { pool_names: { item: resource[:name] }, message => { item: resource[method.to_sym] }}
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

  def member
    result = {}
    addressport = []
    members = []

    members << transport[wsdl].get(:get_member_v2, { pool_names: { item: resource[:name] }})

    members.flatten.each do |hash|
      # If no members are set, you get back a hash with an array in it.
      next unless hash[:address]
      address = hash[:address]
      port    = hash[:port]

      result["#{address}:#{port}"] = {}
      addressport = { address: address, port: port }

      [
        'connection_limit',
        'dynamic_ratio',
        'priority',
        'ratio',
      ].each do |method|
        message = { pool_names: { items: resource[:name] }, members: { items: { items: addressport}}}
        response = transport[wsdl].get("get_member_#{method}".to_sym, message)
        result["#{address}:#{port}"][method] = response
      end
    end
    result
  end

  def member=(value)
    response = []
    response << transport[wsdl].get(:get_member_v2, { pool_names: { item: resource[:name]}})

    current_members = response.flatten.collect { |system|
      next unless system[:address]
      "#{system[:address]}:#{system[:port]}"
    }

    members = resource[:member].keys

    # Should add new members first to avoid removing all members of the pool.
    (members - current_members).each do |node|
      Puppet.debug "Puppet::Provider::F5_Pool: adding member #{node}"
      message = { pool_names: { items: resource[:name] }, members: { items: { items: { address: network_address(node), port: network_port(node) }}}}
      transport[wsdl].call(:add_member_v2, message: message)
    end

    # When provisioning a new pool we won't have members.
    if current_members =! [nil]
      (current_members - members).each do |node|
        Puppet.debug "Puppet::Provider::F5_Pool: removing member #{node}"
        message = { pool_names: { items: resource[:name] }, members: { items: { items: {address: network_address(node), port: network_port(node)}}} }
        transport[wsdl].call(:remove_member_v2, message: message)
      end
    end

    properties = {
      'connection_limit' => 'limits',
      'dynamic_ratio'    => 'dynamic_ratios',
      'priority'         => 'priorities',
      'ratio'            => 'ratios',
    }

    properties.each do |name, message_name|
      value.each do |address,hash|
        address, port = address.split(':')
        message = { pool_names: {items: resource[:name] }, members: {items: { items: { address: address, port: port }}}, message_name => { items: { items: hash[name]}}}
        transport[wsdl].call("set_member_#{name}".to_sym, message: message)
      end
    end
  end

  def monitor_association
    association = nil
    monitor = transport[wsdl].get(:get_monitor_association, { pool_names: { item: resource[:name] }})

    if monitor
      association = {
        'type'              => monitor[:monitor_rule][:type],
        'quorum'            => monitor[:monitor_rule][:quorum],
      }
      if monitor[:monitor_rule][:monitor_templates][:item]
        association['monitor_templates'] = monitor[:monitor_rule][:monitor_templates][:item]
      end
    end
    association
  end

  def monitor_association=(value)
    monitor = resource[:monitor_association]

    if monitor.empty? then
      transport[wsdl].call(:remove_monitor_association, message: { pool_names: { item: resource[:name]}})
    else
      newval = { :pool_name => resource[:name],
        :monitor_rule => {
          :type              => monitor['type'],
          :quorum            => monitor['quorum'],
          :monitor_templates => { items: monitor['monitor_templates'] }
        }
      }

      transport[wsdl].call(:set_monitor_association, message: { monitor_associations: { items: newval }})
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Pool: creating F5 pool #{resource[:name]}")
    # [[]] because we will add members later using member=...
    message = { pool_names: { item: resource[:name] }, lb_methods: { item: resource[:lb_method] }, members: {}}
    transport[wsdl].call(:create_v2, message: message)

    methods = [
      'action_on_service_down',
      'allow_nat_state',
      'allow_snat_state',
      'client_ip_tos',                      # Array
      'client_link_qos',                    # Array
      'gateway_failsafe_device',
      'lb_method',
      'minimum_active_member',              # Array
      'minimum_up_member',                  # Array
      'minimum_up_member_action',
      'minimum_up_member_enabled_state',
      'server_ip_tos',
      'server_link_qos',
      'simple_timeout',
      'slow_ramp_time',
      'monitor_association',
      'member'
    ]

    methods.each do |method|
      self.send("#{method}=", resource[method.to_sym]) if resource[method.to_sym]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Pool: destroying F5 pool #{resource[:name]}")
    transport[wsdl].call(:delete_pool, message: { pool_names: { item: resource[:name]}})
  end

  def exists?
    transport[wsdl].get(:get_list).include?(resource[:name])
  end
end
