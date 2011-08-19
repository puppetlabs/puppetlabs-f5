require 'puppet/provider/f5'

Puppet::Type.type(:f5_certificate).provide(:f5_certificate, :parent => Puppet::Provider::F5 ) do
  @doc = "Manages f5 certificates"

  confine :feature => :posix
  defaultfor :feature => :posix

  F5_WSDL = 'Management.KeyCertificate'

  @f5certs

  def self.instances
    modes = [ "MANAGEMENT_MODE_DEFAULT",
              "MANAGEMENT_MODE_WEBSERVER",
              "MANAGEMENT_MODE_EM",
              "MANAGEMENT_MODE_IQUERY",
              "MANAGEMENT_MODE_IQUERY_BIG3D" ]

    certs = []
    self.cache
    require 'pp'
    pp @f5certs
    modes.each do |mode|
      begin
      certs += transport['Management.KeyCertificate'].get_certificate_list(mode).collect do |cert|
        new(:name => cert.certificate.cert_info.id, :is_bundled => cert.is_bundled, :file_name => cert.file_name, :mode => mode)
      end
      rescue Exception => e
        Puppet.debug("Puppet::Provider::F5_Certificate: ignoring get_certificate_list exception \n #{e.message}")
      end
    end
    certs
  end

  def self.cache
    @f5certs ||= {}

    modes = [ "MANAGEMENT_MODE_DEFAULT",
              "MANAGEMENT_MODE_WEBSERVER",
              "MANAGEMENT_MODE_EM",
              "MANAGEMENT_MODE_IQUERY",
              "MANAGEMENT_MODE_IQUERY_BIG3D" ]

    certs = []
    modes.each do |mode|
      begin
      transport['Management.KeyCertificate'].get_certificate_list(mode).collect do |cert|
        @f5certs[cert.certificate.cert_info.id] = cert
                                                  # { :is_bundled => cert.is_bundled,
                                                  #  :file_name => cert.file_name,
                                                  #  :mode => mode }
        #
        require 'pp'
        pp (cert.methods - SOAP::Mapping::Object.instance_methods).sort
        pp cert.certificate
      end
      rescue Exception => e
        # We simply treat this as no certificates.
        # SOAP::FaultError: Exception caught in Management::urn:iControl:Management/KeyCertificate::get_certificate_list()
        #      error_string         : No such file or directory
        Puppet.debug("Puppet::Provider::F5_Certificate: ignoring get_certificate_list exception \n #{e.message}")
      end
    end
  end


  # need to implement caching for this.
  def cert_info
   'hi hi hi'
  end

  def exists?
    # transport[F5_WSDL].get_list.include?(resource[:name])
    true
  end
end
