require 'puppet/provider/f5'

Puppet::Type.type(:f5_profileclientssl).provide(:f5_profileclientssl, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 device clientssl profile"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.ProfileClientSSL'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  methods = [
    'certificate_file',
    'key_file',
    'ca_file',
    'client_certificate_ca_file',
    'peer_certification_mode',
  ]

  methods.each do |method|
    define_method(method.to_sym) do
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        profile_string = transport[wsdl].send("get_#{method}", resource[:name]).first
        {"value" => profile_string.value, "default_flag" => profile_string.default_flag}
      end
    end
  end

  methods = [
    'certificate_file',
    'key_file',
    'ca_file',
    'client_certificate_ca_file',
  ]

  methods.each do |method|
    define_method("#{method}=") do |profile_string|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", resource[:name],
                             [ :value        => profile_string["value"],
                               :default_flag => profile_string["default_flag"] ])
      end
    end
  end

  def peer_certification_mode=(value)
    transport[wsdl].set_peer_certificate_mode( resource[:name],
                                             [ :value        => resource[:peer_certification_mode]["value"],
                                               :default_flag => resource[:peer_certification_mode]["default_flag"] ])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_ProfileClientSSL: creating F5 client ssl profile #{resource[:name]}")

    transport[wsdl].create([ resource[:name]],
                           [ :value        => resource[:key_file]["value"] ,
                             :default_flag => resource[:key_file]["default_flag"] ],
                           [ :value        => resource[:certificate_file]["value"] ,
                             :default_flag => resource[:certificate_file]["default_flag"] ])

    # It's not clear to me the difference between these two.  We've been
    # setting them to be the same thing.
    ca = resource[:ca_file] || resource[:client_certificate_ca_file]
    if ca
      self.ca_file = ca
      self.client_certificate_ca_file = ca
    end

    if resource[:peer_certification_mode]
      self.peer_certification_mode = resource[:peer_certification_mode]
    end
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_ProfileClientSSL: destroying F5 client ssl profile #{resource[:name]}")
    transport[wsdl].delete_profile([resource[:name]])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
