require 'puppet/provider/f5'

Puppet::Type.type(:f5_user).provide(:f5_user, :parent => Puppet::Provider::F5) do
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
    transport[wsdl].call(:get_list).body[:get_list_response][:return][:item].collect do |item|
      new(:name   => item[:name],
          :ensure => :present
         )
    end
  end

  def create
    Puppet.debug("Puppet::Provider::F5_User: creating F5 user #{resource[:name]}")
    user_info = {
      :user           => { :name => resource[:name], :full_name => resource[:fullname]},
      :password       => { :password => resource[:password]['password'], :is_encrypted => resource[:password]['is_encrypted'] },
      :login_shell    => resource[:login_shell],
      :permissions    => [],
    }
    resource[:user_permission].each do |key, value|
      user_info[:permissions] << { item: { :partition => key, :role => value } }
    end

    # Create_user() and create_user_2() are deprecated and create_user_3()
    # attempts to autodiscover the other values like user_id.

    transport[wsdl].call(:create_user_3, message: {users: {item: [user_info]}})
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_User: destroying F5 user #{resource[:name]}")

    transport[wsdl].call(:delete_user, message: { user_names: { item: resource[:name]}})
  end

  def exists?
    transport[wsdl].call(:get_list).body[:get_list_response][:return][:item].each do |hash|
      return true if hash[:name] == resource[:name]
    end

    return false
  end

  def query_user_property(user, property)
    message = { user_names: { item: Array(user) } }
    result = transport[wsdl].call("get_#{property}".to_sym, message: message).body
    result["get_#{property}_response".to_sym][:return][:item]
  end

  def user_permission
    result = {}
    message = { user_names: { item: Array(resource[:name])}}
    user_permission = transport[wsdl].call(:get_user_permission,
      message: message).body[:get_user_permission_response][:return][:item][:item]

    if user_permission
      result[user_permission[:partition]] = user_permission[:role]
    end

    result
  end

  def user_permission=(value)
    permission = []
    resource[:user_permission].keys.each do |key|
      permission << {:role => resource[:user_permission][key], :partition => key}
    end

    message = { user_names: { item: resource[:name] }, permissions: {item: [permission]} }
    transport[wsdl].call(:set_user_permission, message: message) unless permission.empty?
  end

  def password
    Puppet.debug("Puppet::Provider::F5_User: retrieving encrypted_password for #{resource[:name]}")

    current_password = transport[wsdl].call(:get_encrypted_password, message: { user_names: { :item => [resource[:name]] } }).body[:get_encrypted_password_response][:return][:item]
    result = { "password" => current_password, "is_encrypted" => true }

    # Here we hack around the fact the BIG-IP automatically encrypts any
    # unencrypted password we give it.  We extract the salt from the existing
    # password we retrieved from the BIG-IP, then use it to crypt the
    # unencrypted password we obtained from the resource and if they match we
    # fake the results and pretend what we got was the resource values from the
    # BIG-IP.
    if resource[:password]
      if resource[:password]["is_encrypted"] == false
        salt     = current_password.sub(/^(\$1\$\w+?\$).*$/, '\1')
        existing = resource[:password]["password"].crypt(salt)

        if existing == current_password
          result = { "password" => resource[:password]["password"], "is_encrypted" => false }
        end
      end
    else
    end
    result
  end

  def password=(value)
    Puppet.debug("Puppet::Provider::F5_User: setting password for #{resource[:name]}")
    message = { user_names: { item: resource[:name] }, passwords: { item: { is_encrypted: resource[:password]['is_encrypted'], password: resource[:password]['password'] }}}
    transport[wsdl].call(:change_password_2, message: message)
  end

  def fullname
    query_user_property(resource[:name], 'fullname')
  end

  def fullname=(value)
    message = { user_names: { item: resource[:name] }, fullnames: {item: value} }
    transport[wsdl].call(:set_fullname, message: message)
  end

  def login_shell
    query_user_property(resource[:name], 'login_shell')
  end

  def login_shell=(value)
    message = { user_names: { item: resource[:name] }, shells: {item: value} }
    transport[wsdl].call(:set_login_shell, message: message)
  end

end
