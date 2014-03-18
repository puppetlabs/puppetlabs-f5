require 'puppet/provider/f5'

Puppet::Type.type(:f5_snatpool).provide(:f5_snatpool, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snatpool"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.SNATPool'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    Array(transport[wsdl].get(:get_list)).collect do |name|
      new(:name => name)
    end
  end

  def member
    message = { snat_pools: { item: resource[:name] }}
    transport[wsdl].get(:get_member_v2, message).sort
  end

  def member=(value)
    raise Puppet::Error 'SNAT Pool not found' if ! transport[wsdl].get(:get_list).include?(resource[:name])
    message = { snat_pools: { item: resource[:name] }}
    current_members = transport[wsdl].get(:get_member, message)
    members = resource[:member]

    # Should add first to avoid clearing all members of the snatpool.
    (members - current_members).each do |node|
      Puppet.debug "Puppet::Provider::F5_SNATPool: adding member #{node}"
      message = { snat_pools: { item: resource[:name] }, members: { item: node}}
      transport[wsdl].call(:add_member_v2, message: message)
    end

    (current_members - members).each do |node|
      Puppet.debug "Puppet::Provider::F5_SNATPool: removing member #{node}"
      message = { snat_pools: { item: resource[:name] }, members: { item: node}}
      transport[wsdl].call(:remove_member_v2, message: message)
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_SNATPool: creating F5 snatpool #{resource[:name]}")
    message = { snat_pools: { item: resource[:name] }, translation_addresses: { item: [resource[:member]]}}
    transport[wsdl].call(:create_v2, message: message)
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SNATPool: destroying F5 snatpool #{resource[:name]}")
    message = { snat_pools: { item: resource[:name] }}
    transport[wsdl].call(:delete_snat_pool, message: message)
  end

  def exists?
    transport[wsdl].get(:get_list).include?(resource[:name])
  end
end
