require 'puppet/provider/f5'

Puppet::Type.type(:f5_key).provide(:f5_key, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 cert"

  confine :feature => :posix
  defaultfor :feature => :posix

  @f5keys

  def self.wsdl
    'Management.KeyCertificate'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    unless @f5keys
      self.cache
    end

    @f5keys.collect{ |name, value|
      new(:name => name)
    }
  end

  def self.cache
    @f5keys ||= {}

    modes = [ "MANAGEMENT_MODE_DEFAULT",
              "MANAGEMENT_MODE_WEBSERVER",
              "MANAGEMENT_MODE_EM",
              "MANAGEMENT_MODE_IQUERY",
              "MANAGEMENT_MODE_IQUERY_BIG3D" ]

    modes.each do |mode|
      begin
        transport[wsdl].get_key_list(mode).collect do |key|
          @f5keys[key.key_info.id] = { :info => key.key_info,
                                      :mode => mode }
        end
      rescue Exception => e
        # We simply treat this as no key
        # SOAP::FaultError: Exception caught in Management::urn:iControl:Management/KeyCertificate::get_key_list()
        #      error_string         : No such file or directory
        Puppet.debug("Puppet::Provider::F5_key: ignoring get_key_list exception \n #{e.message}")
      end
    end

    @f5keys
  end

  def self.cache_delete(key)
    @f5keys.delete(key)
  end

  def cache
    self.class.cache
  end

  def cache_delete(key)
    self.class.cache_delete(key)
  end

  def self.lookup(key)
    unless @f5keys and @f5keys[key]
      self.cache
    end

    @f5keys[key]
  end

  def lookup(key)
    self.class.lookup(key)
  end

  # There's no setter for the next two attributes since they are derived values.
  # It's useful for debugging and arguably should not be in the resource type.
  def key_type
    lookup(resource[:name])[:info].key_type
  end

  def security
    lookup(resource[:name])[:info].security
  end

  def create
    transport[wsdl].key_import_from_pem(resource[:managementmode], [resource[:name]], [resource[:content]], true)

    # TODO: need to run this once rather than every time a resource is created.
    self.cache
  end

  def destroy
    transport[wsdl].key_delete(lookup(resource[:name])[:mode], [resource[:name]])

    self.cache_delete(resource[:name])
  end

  def exists?
    lookup(resource[:name])
  end
end
