require 'puppet/provider/f5'

Puppet::Type.type(:f5_user).provide(:f5_user_09, :parent => Puppet::Provider::F5) do
  @doc = "Manages F5 user"

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
    transport[wsdl].get_list.collect do |user|
      new(:name => user.name)
    end
  end

  def password
    # Passing from a password (encrypted) to the same password (unencrypted)
    # won't trigger changes as passwords are always stored in an encrypted form
    # on the bigip. The only consequence is that the crypt salt will remain the
    # same.
    Puppet.debug("Puppet::Provider::F5_User: retrieving encrypted_password for #{resource[:name]}")
    
    old_encrypted_password=transport[wsdl].get_encrypted_password(resource[:name]).first
    
    result = { 'password' => old_encrypted_password, 'is_encrypted' => true }
    
    # resource is an object when this method is called from instances (?!)
    if resource.is_a?(Hash)
      if resource[:password]['is_encrypted'] != true
        salt = old_encrypted_password.sub(/^(\$1\$\w+?\$).*$/, '\1')
        new_encrypted_password = resource[:password]['password'].crypt(salt)
      else
        new_encrypted_password = resource[:password]['password']
      end
      if new_encrypted_password == old_encrypted_password
        result['password']     = resource[:password]['password']
        result['is_encrypted'] = resource[:password]['is_encrypted']
      end
    end
    result
  end

  def password=(value)
    Puppet.debug("Puppet::Provider::F5_User: setting password for #{resource[:name]}")
    transport[wsdl].change_password_2([resource[:name]],[{ :password => resource[:password]['password'], :is_encrypted => resource[:password]['is_encrypted'] }])
  end
  
  methods = [
    'fullname',
    'login_shell',
    'home_directory',
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
      :password       => { :password => resource[:password]['password'], :is_encrypted => resource[:password]['is_encrypted'] },
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
    users = transport[wsdl].get_list.collect{ |u| u.name }
    users.include? resource[:name]
  end
end