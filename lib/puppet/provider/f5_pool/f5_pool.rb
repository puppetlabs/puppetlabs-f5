require 'f5-icontrol'

Puppet::Type.type(:f5_pool).provide(:f5_pool) do
  @doc = "Manages f5 pool"

  # This is to mask the default provider which allows glance installation and management in a single puppet run.
  confine :feature => :posix
  defaultfor :feature => :posix

  @pool

  ip       = '172.16.182.250'
  username = 'admin'
  password = 'admin'
  @@bigip  = F5::IControl.new(ip, username, password, ["LocalLB.Pool"]).get_interfaces

  def self.instances
    #unless @virtual_server
    #  self.cache
    #end

    # we only need to implement parameters since puppet will check properties
    @@bigip["LocalLB.Pool"].get_list.collect do |pool|
      new(:name => pool)
    end
  end

  def self.cache()
    @pool ||= {}

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

  def member
    status = @@bigip["LocalLB.Pool"].get_member(resource[:name])

    status[0].collect { |system|
      "#{system.address}:#{system.port}"
    }
  end

  def minimum_active_member
    (@@bigip["LocalLB.Pool"].get_minimum_active_member(resource[:name]))[0]
  end

  def minimum_up_member
    (@@bigip["LocalLB.Pool"].get_minimum_up_member(resource[:name]))[0]
  end

  def minimum_up_member_action
    (@@bigip["LocalLB.Pool"].get_minimum_up_member_action(resource[:name]))[0]
  end

  def minimum_up_member_enabled_state
    (@@bigip["LocalLB.Pool"].get_minimum_up_member_enabled_state(resource[:name]))[0]
  end

  def version
    @@bigip["LocalLB.Pool"].get_version()
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Pool: destroying resource #{resource[:name]}")
    @@bigip["LocalLB.Pool"].delete_pool(resource[:name])
  end

  def exists?
    #vm(resource[:name])
    true
  end
end
