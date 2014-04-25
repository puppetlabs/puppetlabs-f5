require 'puppet/provider/f5'

Puppet::Type.type(:f5_inet).provide(:f5_inet, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 inet properties"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'System.Inet'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    [new(:name => transport[wsdl].call(:get_hostname).body[:get_hostname_response][:return])]
  end

  def hostname
    transport[wsdl].call(:get_hostname).body[:get_hostname_response][:return]
  end

  def hostname=(value)
    transport[wsdl].call(:set_hostname, message: { hostname: resource[:hostname]})
  end

  def ntp_server_address
    value = transport[wsdl].call(:get_ntp_server_address).body[:get_ntp_server_address_response][:return]
    # The API returns <null> if an ntp server has been added and removed.
    # Otherwise it returns no [:item] and the return of value[:item] will
    # return nil.  F5's can be weird.
    value[:item] == '<null>' ? '' : value[:item]
  end

  def ntp_server_address=(value)
    transport[wsdl].call(:set_ntp_server_address, message: {ntp_addresses: {item: resource[:ntp_server_address]}})
  end

end
