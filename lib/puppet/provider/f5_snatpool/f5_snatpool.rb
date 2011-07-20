require 'puppet/provider/f5'

Puppet::Type.type(:f5_snatpool).provide(:f5_snatpool, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snatpool"

  confine :feature => :posix
  defaultfor :feature => :posix

  F5_WSDL = 'LocalLB.SNATPool'

  def self.instances
    transport[F5_WSDL].get_list.collect do |name|
      new(:name => name)
    end
  end

  def member
    result = transport[F5_WSDL].get_member(resource[:name]).first.join(',')
    puts "'#{result.inspect}'"
    puts "'#{resource[:member].inspect}'"
  end

  def member=(value)
    raise Puppet::Error 'SNAT Pool not found' if ! transport[F5_WSDL].get_list.include?(resource[:name])
    members = transport[F5_WSDL].get_member(resource[:name]).first

    # Should add first to avoid clearing all members of the snatpool.
    (resource[:member] - members).each do |node|
      Puppet.debug "Puppet::Provider::F5_SNATPool: adding member #{node}"
      transport[F5_WSDL].add_member(resource[:name], node)
    end

    (members - resource[:member]).each do |node|
      Puppet.debug "Puppet::Provider::F5_SNATPool: removing member #{node}"
      transport[F5_WSDL].remove_member(resource[:name], node)
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_SNATPool: creating F5 snatpool #{resource[:name]}")
    transport[F5_WSDL].create(resource[:name], [resource[:member]])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SNATPool: destroying F5 snatpool #{resource[:name]}")
    transport[F5_WSDL].delete_snat_pool(resource[:name])
  end

  def exists?
    transport[F5_WSDL].get_list.include?(resource[:name])
  end
end
