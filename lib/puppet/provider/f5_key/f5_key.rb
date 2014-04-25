require 'puppet/provider/f5'

Puppet::Type.type(:f5_key).provide(:f5_key, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 cert"

  confine :feature => :posix
  defaultfor :feature => :posix

  mk_resource_methods

  def self.wsdl
    'Management.KeyCertificate'
  end

  def wsdl
    self.class.wsdl
  end

  def self.modes
    %w(MANAGEMENT_MODE_DEFAULT MANAGEMENT_MODE_WEBSERVER MANAGEMENT_MODE_EM MANAGEMENT_MODE_IQUERY MANAGEMENT_MODE_IQUERY_BIG3D)
  end

  def self.instances
    f5keys = Array.new

    self.modes.each do |mode|
      begin
        transport[wsdl].call(:get_key_list, message: {mode: mode}).body[:get_key_list_response][:return][:item].collect do |hashes|
          key = {
            :name   => hashes[:key_info][:id],
            :ensure => :present,
            :mode   => mode
          }
          f5keys << new(key)
        end
      rescue Exception => e
        Puppet.debug("Puppet::Provider::F5_key: ignoring get_key_list exception \n #{e.message}")
      end
    end
    f5keys
  end

  # Modify each key to have its instance as the provider
  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def content
    message = { mode: resource[:mode], key_ids: {item: self.name}}
    value = transport[wsdl].call(:key_export_to_pem, message: message).body[:key_export_to_pem_response][:return][:item]

    keys = value.scan(/([-| ]*BEGIN [R|D]SA (?:PRIVATE|PUBLIC) KEY[-| ]*.*?[-| ]*END [R|D]SA (?:PRIVATE|PUBLIC) KEY[-| ]*)/m).flatten

    keys_sha1 = keys.collect { |key|
      Puppet::Util::NetworkDevice::F5.fingerprint(key)
    }

    "sha1(#{keys_sha1.sort.inspect})"
  end

  def content=(value)
    Puppet.debug("Puppet::Provider::F5_key: replacing key #{self.name}")

    # Replace key/cert altogether in one step if they are bundled.
    if resource[:real_content].match(/([-| ]*BEGIN CERTIFICATE[-| ]*.*?[-| ]*END CERTIFICATE[-| ]*)/m)
      message = { mode: resource[:mode], key_ids: { item: self.name }}
      transport[wsdl].call(:key_delete, message: message)
      transport[wsdl].call(:certificate_delete, message: message)
      message = { mode: resource[:mode], key_ids: { item: self.name }, pem_data: { item: resource[:real_contentlib/puppet/type/f5_key.rb
      transport[wsdl].call(:key_import_from_pem, message: message)
      transport[wsdl].call(:certificate_import_from_pem, message: message)
    else
      message = { mode: resource[:mode], key_ids: { item: self.name }, pem_data: { item: resource[:real_content] }, overwrite: true }
      transport[wsdl].call(:key_import_from_pem, message: message)
    end
  end

  def create
    @property_hash[:ensure] = :present
    content= @resource.should(:content)
  end

  def destroy
    @property_hash[:ensure] = :absent
    transport[wsdl].call(:key_delete, message: { mode: resource[:mode], key_ids: { item: self.name }})
  end

  def exists?
    @property_hash[:ensure] == :present
  end

end
