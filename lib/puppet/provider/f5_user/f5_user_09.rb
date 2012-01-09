require 'puppet/provider/f5'

Puppet::Type.type(:f5_user).provide(:f5_user_09, :parent => Puppet::Provider::F5) do
  @doc = "Manages F5 user"

  #confine :true => false
  
  confine    :true  => (Gem::Version.new(Puppet::Util::NetworkDevice.current.facts['version'].sub('BIG-IP_v','')) >= Gem::Version.new('9.0.0'))
  confine    :false => (Gem::Version.new(Puppet::Util::NetworkDevice.current.facts['version'].sub('BIG-IP_v','')) >= Gem::Version.new('10.0.0'))
  
  confine    :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Management.UserManagement'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    Puppet.debug("Puppet::Provider::F5_User: instances")
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [ 'description',
      'fullname',
      'login_shell',
      'home_directory',
      'user_id',
      'group_id',
      'role'
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        Puppet.debug("Puppet::Provider::F5_User: retrieving #{method} for #{resource[:name]}")
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

  def create
    Puppet.debug("Puppet::Provider::F5_User: creating F5 user #{resource[:name]}")
 
    user_info_2 = {
      :user           => { :name => resource[:name], :full_name => resource[:fullname]},
      :password       => { :password => resource[:password], :is_encrypted => false },
      :home_directory => resource[:home_directory],
      :login_shell    => resource[:login_shell],
      :user_id        => resource[:user_id],
      :group_id       => resource[:group_id],
      :role           => resource[:role],
    }

    
    transport[wsdl].create_user_2([user_info_2])

  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_User: destroying F5 user #{resource[:name]}")
    transport[wsdl].delete_user(resource[:name])
  end

  def exists?
    r = false
    transport[wsdl].get_list.each do |u|
      if u.name == resource[:name]
        r = true
        break
      end
    end
    Puppet.debug("Puppet::Provider::F5_User: does F5 user #{resource[:name]} exists ? #{r}")
    Puppet.debug("Puppet::Provider::F5_User: device #{device}")
    v=Puppet::Util::NetworkDevice.current.facts['version']
    Puppet.debug("Puppet::Provider::F5_User: facter version : #{v}")
    r
  end
end
