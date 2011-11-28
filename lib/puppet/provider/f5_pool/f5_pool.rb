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
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [
    'action_on_service_down',
    'allow_nat_state',
    'allow_snat_state',
    'client_ip_tos',                      # Array
    'client_link_qos',                    # Array
    'gateway_failsafe_device',
    'gateway_failsafe_unit_id',           # Array
    'lb_method',
    'minimum_active_member',              # Array
    'minimum_up_member',                  # Array
    'minimum_up_member_action',
    'minimum_up_member_enabled_state',
    'server_ip_tos',
    'server_link_qos',
    'simple_timeout',
    'slow_ramp_time'
  ]

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

  def member
    result = {}

    members = transport[wsdl].get_member(resource[:name]).first
    members.each { |system|
      result["#{system.address}:#{system.port}"] = {}
    }

    # does not support v11 wsdl
    wsdl = 'LocalLB.PoolMember'

    methods = [
      'connection_limit',
      'dynamic_ratio',
      'priority',
      'ratio',
    ]

    methods.each do |method|
      value = transport[wsdl].send("get_#{method}", resource[:name]).first
      value.each do |val|

        # F5 A.B.C.D%ID routing domain requires special handling.
        #   If we don't detect a routine domain in get_member, we ignore %ID.
        #   If we detect routine domain in get_member, we provide %ID.
        address = val.member.address
        noroute = address.split("%").first
        port    = val.member.port

        if result.member?("#{address}:#{port}")
          result["#{address}:#{port}"][method] = val.send(method).to_s
        elsif result.member?("#{noroute}:#{port}")
          result["#{noroute}:#{port}"][method] = val.send(method).to_s
        else
          raise Puppet::Error, "Puppet::Provider::F5_Pool: LocalLB.PoolMember get_#{method} returned #{address}:#{port} that does not exist in get_member."
         end
      end
    end

    result
  end

  def member=(value)
    current_members = transport[wsdl].get_member(resource[:name]).first
    current_members = current_members.collect { |system|
      "#{system.address}:#{system.port}"
    }

    members = resource[:member].keys

    # Should add new members first to avoid removing all members of the pool.
    (members - current_members).each do |node|
      Puppet.debug "Puppet::Provider::F5_Pool: adding member #{node}"
      transport[wsdl].add_member(resource[:name],
        [[{:address => network_address(node),
           :port    => network_port(node)}]])
    end

    (current_members - members).each do |node|
      Puppet.debug "Puppet::Provider::F5_Pool: removing member #{node}"
      transport[wsdl].remove_member(resource[:name],
        [[{:address => network_address(node),
           :port    => network_port(node)}]])
    end

    # does not support v11 wsdl
    wsdl = 'LocalLB.PoolMember'

    methods = [
      'connection_limit',
      'dynamic_ratio',
      'priority',
      'ratio',
    ]

    methods.each do |m|

      # converts the value from ip:netmask => { 'priority' => '1', 'ratio' => '1' } to
      # { :member   => {:address => ip, :port => port},
      #   :priority => '1' }
      # { :member   => {:address => ip, :port => port},
      #   :ratio    => '1' }
      r = Hash[*resource[:member].select {|k,v| v.include?(m)}.flatten]
      r = r.collect do |k,v|
        {:member => {:address => network_address(k), :port => network_port(k)}, m.to_s => v[m]}
      end

      value = transport[wsdl].send("set_#{m}", [resource[:name]], [r]) unless r.empty?
    end
  end

  def monitor_association
    monitor = transport[wsdl].get_monitor_association(resource[:name]).first.monitor_rule

    { 'type' => monitor.type, 'quorum' => monitor.quorum.to_s, 'monitor_templates' => monitor.monitor_templates }
  end

  def monitor_association=(value)
    monitor = resource[:monitor_association]

    if monitor.empty? then
      transport[wsdl].remove_monitor_association(resource[:name])
    else
      newval = { :pool_name    => resource[:name],
                 :monitor_rule => { :type              => monitor['type'],
                                    :quorum            => monitor['quorum'],
                                    :monitor_templates => monitor['monitor_templates'] }
               }

      transport[wsdl].set_monitor_association([newval])
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Pool: creating F5 pool #{resource[:name]}")
    # [[]] because we will add members later using member=...
    transport[wsdl].create(resource[:name], resource[:lb_method], [[]])

    methods = [
      'action_on_service_down',
      'allow_nat_state',
      'allow_snat_state',
      'client_ip_tos',                      # Array
      'client_link_qos',                    # Array
      'gateway_failsafe_device',
      'gateway_failsafe_unit_id',           # Array
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
    transport[wsdl].delete_pool(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
