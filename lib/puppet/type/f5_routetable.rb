Puppet::Type.newtype(:f5_routetable) do
  @doc = "Manage F5 routing table."

  apply_to_device

  newparam(:name, :namevar=>true) do
    desc "The routetable name. Can be either 'static' or 'management'."
    newvalues(/^(static|management)$/)
  end

  newproperty(:table, :array_matching => :all) do
    desc "The routing table."
    validate do |value|
      i=0
      ['gateway','vlan','pool'].each do |type|
        i=i+1 if value[type]
      end
      Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: validation : #{value.inspect}") 
      
      raise Puppet::Error, 'Pupppet::Type::F5_RouteTable: You must define only either gateway, vlan or pool.' unless i <= 1
      raise Puppet::Error, 'Pupppet::Type::F5_RouteTable: destination must be a valid IP address.' unless value['destination'] =~/^[0-9A-Fa-f\.\:]+$/
      raise Puppet::Error, "Pupppet::Type::F5_RouteTable: gateway #{value['gateway'].inspect} must be a valid IP address." unless value['gateway'] == nil || value['gateway'] =~/^[0-9A-Fa-f\.\:]+$/
      raise Puppet::Error, 'Pupppet::Type::F5_RouteTable: netmask must be a valid network mask address.' unless value['netmask'] =~/^[0-9A-Fa-f\.\:]+$/
      raise Puppet::Error, 'Pupppet::Type::F5_RouteTable: MTU must be an integer.' unless value['mtu'] =~ /^\d+$/
    end
    def insync?(is)
      is.count == should.count && (is&should).count == should.count
    end
    
    def should_to_s(newvalue)
      newvalue.inspect
    end
    def is_to_s(currentvalue)
      currentvalue.inspect
    end
  end
  
  autorequire(:f5_vlan) do
    vlans=[]
    self[:table].each do |t|
      if t['vlan']
        vlans.push(t['vlan'])
      end
    end
    vlans
  end  
  autorequire(:f5_pool) do
    pools=[]
    self[:table].each do |t|
      if t['pool']
        pools.push(t['pool'])
      end
    end
    pools
  end
  autorequire(:f5_licence) do
    ['license']
  end
  
end
