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

  # Our instances method grabs the current target f5 state of all keys. This
  # instances method is called by the parent Puppet::Provider::F5 class's
  # prefetch method (not yet written, currently in this class). Prefetch is what
  # populates @property_hash for use when checking the keys' installation state.
  def self.instances
    f5keys = Array.new
    key = Hash.new
    modes = [ "MANAGEMENT_MODE_DEFAULT",
              "MANAGEMENT_MODE_WEBSERVER",
              "MANAGEMENT_MODE_EM",
              "MANAGEMENT_MODE_IQUERY",
              "MANAGEMENT_MODE_IQUERY_BIG3D" ]
    modes.each do |mode|
      begin
        transport[wsdl].get_key_list(mode).collect do |key|
          key = {
            :name           => key.key_info.id,
            :ensure         => 'present',
            :key_type       => key.key_info.key_type,
            :security       => key.key_info.security,
            :managementmode => mode
          }
          f5keys << new(key)
        end
      rescue Exception => e
        # We simply treat this as no key
        # SOAP::FaultError: Exception caught in Management::urn:iControl:Management/KeyCertificate::get_key_list()
        #      error_string         : No such file or directory
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

  def flush
    @property_hash.clear
  end

  def create
    @property_hash[:ensure] = :present
    self.class.resource_type.validproperties.each do |property|
      if val = resource.should(property)
        @property_hash[property] = val
      end
    end
    transport[wsdl].key_import_from_pem(resource[:managementmode], [resource[:name]], [resource[:content]], true)
  end

  def destroy
    @property_hash[:ensure] = :absent
    transport[wsdl].key_delete(@property_hash[:managementmode], [@property_hash[:name]])
  end

  def exists?
    Puppet.debug("Puppet::Provider::F5_key::Ensure for #{@property_hash[:name]}: #{@property_hash[:ensure]}")
    @property_hash[:ensure] != :absent
  end
end
