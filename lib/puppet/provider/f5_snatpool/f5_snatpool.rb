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
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  def member
    result = transport[wsdl].get_member(resource[:name]).first.sort.join(',')
  end

  def member=(value)
    raise Puppet::Error 'SNAT Pool not found' if ! transport[wsdl].get_list.include?(resource[:name])
    current_members = transport[wsdl].get_member(resource[:name]).first
    members = resource[:member].split(',')

    # Should add first to avoid clearing all members of the snatpool.
    (members - current_members).each do |node|
      Puppet.debug "Puppet::Provider::F5_SNATPool: adding member #{node}"
      transport[wsdl].add_member(resource[:name], node)
    end

    (current_members - members).each do |node|
      Puppet.debug "Puppet::Provider::F5_SNATPool: removing member #{node}"
      transport[wsdl].remove_member(resource[:name], node)
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_SNATPool: creating F5 snatpool #{resource[:name]}")
    transport[wsdl].create(resource[:name], [resource[:member]])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_SNATPool: destroying F5 snatpool #{resource[:name]}")
    transport[wsdl].delete_snat_pool(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
