require 'f5-icontrol'

Puppet::Type.type(:f5_virtualserver).provide(:f5_virtualserver) do
  @doc = "Manages f5 device"

  # This is to mask the default provider which allows glance installation and management in a single puppet run.
  confine :feature => :posix
  defaultfor :feature => :posix

  #commands :glance => "glance"
  #
  @virtual_server

  ip       = '172.16.182.250'
  username = 'admin'
  password = 'admin'
  @@bigip  = F5::IControl.new(ip, username, password, ["LocalLB.VirtualServer"]).get_interfaces

  def self.instances
    #unless @virtual_server
    #  self.cache
    #end

    # we only need to implement parameters since puppet will check properties
    @@bigip["LocalLB.VirtualServer"].get_list.collect do | server|
    #result.each do |server|
      Puppet.debug(server.class)
      Puppet.debug(server)
      new(:name => server)
    end
  end

  def self.cache()
    @virtual_server ||= {}

    # retreive list of image ids with glance index.
    #if lookup == []
    #  Puppet.debug "Puppet::Provider::Glance: creating cache of all vm instances."
    #  image_ids = glance('index').split("\n").collect { |line|
    #    $1 if line =~ %r(^(\d+)\s+\S+)
    #  }.compact!
    #else
    #  Puppet.debug "Puppet::Provider::Glance: reloading cache of vm instances #{lookup}."
    #  image_ids = lookup
    #end

    ## retrieve detail information for each image id
    #Puppet.debug "Puppet::Provider::F5_VirtualServer: \n"+@glance.inspect
  end


  def self.vm(lookup)
    # This results in two lookups if a resource does not exists but it's necessary
    unless @glance and @glance[lookup]
      self.cache
    end

    @glance[lookup]
  end

  # not sure if this is necessary since everything should call self.class.vm
  def vm(lookup)
    self.class.vm(lookup)
  end

  def availability_status
    status = @@bigip["LocalLB.VirtualServer"].get_object_status(resource[:name])
    status[0].availability_status
  end

  def enabled_status
    status = @@bigip["LocalLB.VirtualServer"].get_object_status(resource[:name])
    status[0].enabled_status
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_VirtualServer: destroying resource #{resource[:name]}")
    @@bigip["LocalLB.VirtualServer"].delete_virtual_server(resource[:name])
  end

  def exists?
    #vm(resource[:name])
    true
  end
end
