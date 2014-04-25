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
    Array(transport[wsdl].get(:get_list)).collect do |name|
      new(:name => name, :ensure => :present)
    end
  end

  def self.prefetch(resources)
    profileclientssl = instances
    resources.keys.each do |name|
      if provider = profileclientssl.find { |ssl| ssl.name == name }
        resources[name].provider = provider
      end
    end
  end

  # Does the filtering of the responses for us.
  def return_value(response)
    value = response[:value].is_a?(String) ? response[:value] : ''
    { :value => value, :default_flag => response[:default_flag].to_s }
  end

  def certificate_file
    message = { profile_names: { item: resource[:name] }}
    response = transport[wsdl].get(:get_certificate_file_v2, message)
    return_value(response)
  end

  def certificate_file=(value)
    existing_key = key_file
    message = {
      profile_names: { item: resource[:name] },
      keys: { item: { value: existing_key[:value], default_flag: existing_key[:default_flag] }},
      certs: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_key_certificate_file, message: message)
  end

  def key_file
    message = { profile_names: { item: resource[:name] }}
    response = transport[wsdl].get(:get_key_file_v2, message)
    return_value(response)
  end

  def key_file=(value)
    existing_cert = certificate_file
    message = {
      profile_names: { item: resource[:name] },
      certs: { item: { value: existing_cert[:value], default_flag: existing_cert[:default_flag] }},
      keys: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_key_certificate_file, message: message)
  end

  def ca_file
    message = { profile_names: { item: resource[:name] }}
    response = transport[wsdl].get(:get_ca_file_v2, message)
    return_value(response)
  end

  def ca_file=(value)
    message = {
      profile_names: { item: resource[:name] },
      cas: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_ca_file_v2, message: message)
  end

  def client_certificate_ca_file
    message = { profile_names: { item: resource[:name] }}
    response = transport[wsdl].get(:get_client_certificate_ca_file_v2, message)
    return_value(response)
  end

  def client_certificate_ca_file=(value)
    message = {
      profile_names: { item: resource[:name] },
      client_cert_cas: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_client_certificate_ca_file_v2, message: message)
  end

  def peer_certification_mode
    message = { profile_names: { item: resource[:name] }}
    response = transport[wsdl].get(:get_peer_certification_mode, message)
    return_value(response)
  end

  def peer_certification_mode=(value)
    message = {
      profile_names: { item: resource[:name] },
      modes: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_peer_certificate_mode, message: message)
  end

  def chain_file
    message = { profile_names: { item: resource[:name] }}
    response = transport[wsdl].get(:get_chain_file_v2, message)
    return_value(response)
  end

  def chain_file=(value)
    message = {
      profile_names: { item: resource[:name] },
      chains: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_chain_file_v2, message: message)
  end

  def peer_certification_mode=(value)
    message = {
      profile_names: { item: resource[:name] },
      modes: { item: { value: value[:value], default_flag: value[:default_flag] }},
    }
    transport[wsdl].call(:set_peer_certificate_mode, message: message)
  end

  def create
    message = {
      profile_names: { item: resource[:name] },
      keys: {
        item: {
          value: resource['key_file'][:value],
          default_flag: resource['key_file'][:default_flag]
        }
      },
      certs: {
        item: {
          value: resource['certificate_file'][:value],
          default_flag: resource['certificate_file'][:default_flag]
        }
      }
    }
    transport[wsdl].call(:create_v2, message: message)

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

    if resource[:chain_file]
      self.chain_file = resource[:chain_file]
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    message = { profile_names: { item: resource[:name] }}
    transport[wsdl].call(:delete_profile, message: message)
    @property_hash[:ensure] = :absent
  end

  def exists?
    @property_hash[:ensure] == :present
  end
end
