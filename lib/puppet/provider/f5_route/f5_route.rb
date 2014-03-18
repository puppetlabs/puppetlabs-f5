require 'puppet/provider/f5'

Puppet::Type.type(:f5_route).provide(:f5_route, :parent => Puppet::Provider::F5) do
  @doc = 'Manage F5 static routes.'

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Networking.RouteTableV2'
  end
  def wsdl
    self.class.wsdl
  end

  def self.instances
    instances = []
    get_routes.each do |route_name|
      instances << new(name: route_name, ensure: :present)
    end
    instances
  end

  def self.prefetch(resources)
    routes = instances
    resources.keys.each do |name|
      if provider = routes.find { |route| route.name == name }
        resources[name].provider = provider
      end
    end
  end

  def destroy
    message = { routes: { item: resource[:name] }}
    transport[wsdl].call(:delete_static_route, message: message)

    @property_hash[:ensure] = :absent
  end

  def create
    message = {
      routes:       { item: resource[:name] },
      destinations: { item:
                      { address: resource[:destination],
                        netmask: resource[:netmask] }
      },
      attributes:   { item:
                      # Handle reject properly.
                      { gateway: resource[:gateway] == 'reject' ? nil : gateway,
                        vlan_name: resource[:vlan],
                        pool_name: resource[:pool] }
      },
    }
    transport[wsdl].call(:create_static_route, message: message)

    # Set the route to reject if needed.
    if resource[:gateway] == 'reject'
      gateway=(resource[:gateway])
    end

    # Can't set a description when creating the route.
    if resource[:description]
      description=(resource[:description])
    end
    @property_hash[:ensure] = :present

  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destination
    message = { routes: { item: self.name }}
    response = transport[wsdl].get(:get_static_route_destination, message)
    return response[:address]
  end

  # Unfortunately you can't change the destination.
  def destination=(value)
    Puppet.debug('Cannot change this value, destroying and recreating.')
    destroy
    create
  end

  def netmask
    message = { routes: { item: self.name }}
    response = transport[wsdl].get(:get_static_route_destination, message)
    return response[:netmask]
  end

  # Unfortunately you can't change the netmask either.
  def netmask=(value)
    Puppet.debug('Cannot change this value, destroying and recreating.')
    destroy
    create
  end

  def description
    message = { routes: { item: self.name }}
    transport[wsdl].get(:get_static_route_description, message)
  end

  def description=(value)
    message = {
      routes: { item: self.name },
      descriptions: { item: resource[:description] },
    }
    transport[wsdl].call(:set_static_route_description, message: message)
  end

  def gateway
    message = { routes: { item: self.name }}
    response = transport[wsdl].get(:get_static_route_gateway, message)
    # Internally the F5 represents reject as an ipv6 address.
    return 'reject' if response == '0:0:0:0:0:0:0:0'
    return response
  end

  def gateway=(value)
    # Handle values of reject.
    if value == 'reject'
      message = { routes: { item: self.name }}
      transport[wsdl].call(:set_static_route_reject, message)
    else
      message = {
        routes: { item: self.name },
        gateways: { item: resource[:gateway] },
      }
      transport[wsdl].call(:set_static_route_gateway, message: message)
    end
  end

  def mtu
    message = { routes: { item: self.name }}
    transport[wsdl].get(:get_static_route_mtu, message)
  end

  def mtu=(value)
    message = {
      routes: { item: self.name },
      mtus:   { item: resource[:mtu] },
    }
    transport[wsdl].call(:set_static_route_mtu, message: message)
  end

  def pool
    message = { routes: { item: self.name }}
    transport[wsdl].get(:get_static_route_pool, message)
  end

  def pool=(value)
    message = {
      routes: { item: self.name },
      pools:  { item: resource[:pool] },
    }
    transport[wsdl].call(:set_static_route_pool, message: message)
  end

  def vlan
    message = { routes: { item: self.name }}
    transport[wsdl].get(:get_static_route_vlan, message)
  end

  def vlan=(value)
    message = {
      routes: { item: self.name },
      vlans:  { item: resource[:vlan] },
    }
    transport[wsdl].call(:set_static_route_vlan, message: message)
  end

  # Obtain a list of static routes.
  def self.get_routes
    response = transport[wsdl].get(:get_static_route_list)
    return Array(response)
  end


end
