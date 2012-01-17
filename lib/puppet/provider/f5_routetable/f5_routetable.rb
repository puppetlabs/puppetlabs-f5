require 'puppet/provider/f5'

Puppet::Type.type(:f5_routetable).provide(:f5_routetable, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 routing table."

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.RouteTable'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  def table
    #
    # We build here the device's routing table data structure.
    # We minimize the number of SOAP calls, so that we need to use intermediate data structures
    #
    
    #
    # We retrieve all the routes
    #
    Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Query all routes") 
    entries=transport[wsdl].send("get_#{resource[:name]}_route").collect { |route|
      { 'destination' => route.destination, 'netmask' => route.netmask }
    }
    
    #
    # We build a hash containing all routes of a given type
    #
    route_types={}
    Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Query routes types") 
    transport[wsdl].send("get_#{resource[:name]}_route_type", entries).each_with_index do |type, i|
      type.sub!('ROUTE_TYPE_','').downcase!
      if type=='interface' # Work around inconsistent naming convention
         type='vlan'
      end
      if type != 'reject' # reject type is defined by the absence of other types
        if route_types[type] == nil
          route_types[type]=[]
        end
        route_types[type].push(entries[i])
      end
    end

    #
    # For each type, we retrieve all route type values
    # We build a hash containing route type and value of each route
    #
    types_values={}
    route_types.keys.each do |type|
      Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Query routes type #{type} values") 
      transport[wsdl].send("get_#{resource[:name]}_route_#{type}", route_types[type]).each_with_index do |value, i|
        types_values[route_types[type][i]]={:type => type , :value => value}
      end
    end
    
    #
    # We retrieve all routes' MTUs
    #
    Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Query routes MTUs") 
    rtmtus=transport[wsdl].send("get_#{resource[:name]}_route_mtu", entries)
    
    #
    # We merge all the stuff into the final data structure
    #
    entries.each_with_index do |entry, i|
      if types_values[entry] != nil
        entry.merge!({types_values[entry][:type]=>types_values[entry][:value]})
      end
      entry.merge!({'mtu'=>rtmtus[i].to_s})
    end
    
    #
    # We save it for further use
    #
    @device_route_table=entries
  end

  
  def table=(value)
    #
    # Again, we minimize the number of SOAP calls, so that we need to determine
    # the entries to add, to remove and modify
    #
    
    
    # We build a hash with the routes and values actually present in the device
    # 
    cur_entries=build_entries(@device_route_table)
    
    # We build a hash with the wanted routes and values
    #
    new_entries=build_entries(value)

    #
    # We determine the routes to be added to and removed from the device
    # 
    add=(new_entries.keys - cur_entries.keys)
    del=(cur_entries.keys - new_entries.keys)
    
    #
    # We build an array containing the values to add to the device
    # 
    add_values=[]
    add_mtus=[]
    add.each do |k|
      add_values.push(new_entries[k])
      add_mtus.push(new_entries[k]['mtu'])
    end
    
    #
    # We add the new routes and their values to the device
    # 
    if !add.empty?
      Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Add #{add.count} route entries : #{add.inspect}") 
      transport[wsdl].send("add_#{resource[:name]}_route", add, add_values)
      transport[wsdl].send("set_#{resource[:name]}_route_mtu", add, add_mtus)
    end

    #
    # We remove the obsolete routes from the device
    # 
    if !del.empty?
      Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Delete #{del.count} route entries : #{del.inspect}") 
      transport[wsdl].send("delete_#{resource[:name]}_route", del)
    end
    
    
    #
    # We build a hash containing the modified MTUs and a hash containing the modified types
    # 
    mod_mtus={}
    mod_type={'gateway'=>{},'vlan'=>{},'pool'=>{},'reject'=>{}}
    (new_entries.keys & cur_entries.keys).each do |k|
      if cur_entries[k] != new_entries[k]
        if cur_entries[k]['mtu'] != new_entries[k]['mtu']
          Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Route #{k.inspect} MTU has changed from #{cur_entries[k]['mtu']} to #{new_entries[k]['mtu']}") 
          mod_mtus[k]=new_entries[k]['mtu']
        end
        if cur_entries[k]['gateway'] != new_entries[k]['gateway'] && new_entries[k]['gateway']
          Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Route #{k.inspect} has changed its GATEWAY from '#{cur_entries[k]['gateway']}' to #{new_entries[k]['gateway']}") 
          mod_type['gateway'][k]=new_entries[k]['gateway']
        elsif cur_entries[k]['vlan_name'] != new_entries[k]['vlan_name'] && new_entries[k]['vlan_name']
          Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Route #{k.inspect} has changed its VLAN from '#{cur_entries[k]['vlan_name']}' to #{new_entries[k]['vlan_name']}") 
          mod_type['vlan'][k]=new_entries[k]['vlan_name']
        elsif cur_entries[k]['pool_name'] != new_entries[k]['pool_name'] && new_entries[k]['pool_name']
          Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Route #{k.inspect} has changed its POOL from '#{cur_entries[k]['pool_name']}' to #{new_entries[k]['pool_name']}")
          mod_type['pool'][k]=new_entries[k]['pool_name']
        elsif !new_entries[k]['gateway'] && !new_entries[k]['vlan_name'] && !new_entries[k]['pool_name']
          Puppet.debug("Puppet::Provider::F5_RouteTable #{resource[:name]}: Route #{k.inspect} has changed to REJECT") 
          mod_type['reject'][k]=true
        end
      end
    end
    
    #
    # We set the modified MTUs
    #
    if !mod_mtus.empty?
      transport[wsdl].send("set_#{resource[:name]}_route_mtu", mod_mtus.keys, mod_mtus.values)
    end
    
    #
    # We set the modified route types
    #
    mod_type.keys.each do |type|
      if !mod_type[type].empty?
        if type == 'reject'
          transport[wsdl].send("set_#{resource[:name]}_route_#{type}", mod_type[type].keys)
        else
          transport[wsdl].send("set_#{resource[:name]}_route_#{type}", mod_type[type].keys, mod_type[type].values)
        end
      end
    end
    
  end
  
  #
  # Build a hash with parameters for each route
  #
  def build_entries(routes)
    entries={}
    routes.each do |route|
      k={ 'destination' => route['destination'], 'netmask' => route['netmask'] }
      entries[k]={ 'mtu' =>  route['mtu'] }
      if route['gateway']
        entries[k]['gateway'] = route['gateway']
      elsif route['vlan']
        entries[k]['vlan_name'] = route['vlan']
      elsif route['pool']
        entries[k]['pool_name'] = route['pool']
      end
    end
    entries
  end
end