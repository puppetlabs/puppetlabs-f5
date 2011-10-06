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

  methods = [ 'action_on_service_down',
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
    'slow_ramp_time']

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
    members = transport[wsdl].get_member(resource[:name]).first
    members = members.collect { |system|
      "#{system.address}:#{system.port}"
    }.sort.join(',')
  end

  def member=(value)
    current_members = transport[wsdl].get_member(resource[:name]).first
    current_members = current_members.collect { |system|
      "#{system.address}:#{system.port}"
    }

    members = resource[:member].split(',')

    # Should add first to avoid clearing all members of the pool.
    (members - current_members).each do |node|
      Puppet.debug "Puppet::Provider::F5_Pool: adding member #{node}"
      transport[wsdl].add_member(resource[:name],
        [[{:address => node.split(':')[0],
           :port    => node.split(':')[1]}]])
    end

    (current_members - members).each do |node|
      Puppet.debug "Puppet::Provider::F5_Pool: removing member #{node}"
      transport[wsdl].remove_member(resource[:name],
        [[{:address => node.split(':')[0],
           :port    => node.split(':')[1]}]])
    end
  end

  def monitor_association
    monitor = transport[wsdl].get_monitor_association(resource[:name]).first.monitor_rule

    { 'type' => monitor.type, 'quorum' => monitor.quorum.to_s, 'monitor_templates' => monitor.monitor_templates }
  end

  def monitor_association=(value)
    monitor = resource[:monitor_association]
    newval = { :pool_name    => resource[:name],
               :monitor_rule => { :type              => monitor['type'],
                                  :quorum            => monitor['quorum'],
                                  :monitor_templates => monitor['monitor_templates'] }
             }

    transport[wsdl].set_monitor_association([newval])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Pool: creating F5 pool #{resource[:name]}")
    # [[]] because we will add members later using member=...
    transport[wsdl].create(resource[:name], resource[:lb_method], [[]])

    methods = [ 'action_on_service_down',
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
    'slow_ramp_time']
    methods << "monitor_association" << "member"
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
