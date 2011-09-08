require 'openssl'
require 'digest/md5'
require 'puppet/provider/f5'

Puppet::Type.type(:f5_certificate).provide(:f5_certificate, :parent => Puppet::Provider::F5 ) do
  @doc = "Manages f5 certificates"

  confine :feature => :posix
  defaultfor :feature => :posix

  @f5certs

  def self.wsdl
    'Management.KeyCertificate'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    unless @f5certs
      self.cache
    end

    @f5certs.collect{ |name, value|
      new(:name => name)
    }
  end

  def self.cache
    @f5certs ||= {}

    modes = [ "MANAGEMENT_MODE_DEFAULT",
              "MANAGEMENT_MODE_WEBSERVER",
              "MANAGEMENT_MODE_EM",
              "MANAGEMENT_MODE_IQUERY",
              "MANAGEMENT_MODE_IQUERY_BIG3D" ]

    modes.each do |mode|
      begin
        transport[wsdl].get_certificate_list(mode).each do |cert|
          # F5 certificate bundles have a single cert id so we can't manage them individually, only as a single bundle.
          cert_id = cert.certificate.cert_info.id
            @f5certs[cert_id] = { :certificate => cert.certificate,
                                  :file_name   => cert.file_name,
                                  :is_bundled  => cert.is_bundled,
                                  :mode        => mode }
        end
      rescue Exception => e
        # We simply treat this as no certificates.
        # SOAP::FaultError: Exception caught in Management::urn:iControl:Management/KeyCertificate::get_certificate_list()
        #      error_string         : No such file or directory
        Puppet.debug("Puppet::Provider::F5_Certificate: ignoring get_certificate_list exception \n #{e.message}")
      end
    end
    @f5certs
  end

  def cache
    self.class.cache
  end

  def self.lookup(key)
    unless @f5certs and @f5certs[key]
      self.cache
    end

    @f5certs[key]
  end

  def lookup(key)
    self.class.lookup(key)
  end

  # This is intended to decode certificate (subject, serial, issuer, expiration) for comparison.
  def decode(content)
    cert = case content.split("\n").first
           when /BEGIN X509 CRL/
             OpenSSL::X509::CRL
           when /BEGIN CERTIFICATE REQUEST/
             OpenSSL::X509::Request
           when /BEGIN CERTIFICATE/
             OpenSSL::X509::Certificate
           when /BEGIN RSA (PRIVATE|PUBLIC) KEY/
             OpenSSL::PKey::RSA
           else return nil
           end
    cert.new(content)
  rescue Exception => e
    Puppet.debug("Puppet::Provider::F5_Cert: failed to decode certificate #{resource[:name]} content. Error: #{e.message}")
  end

  # Calculate cert fingerprint
  def fingerprint(content)
    cert = decode(content)
    Digest::SHA1.hexdigest(cert.to_der)
  end

  def content
    cert = transport[wsdl].certificate_export_to_pem(lookup(resource[:name])[:mode], resource[:name]).first
    "sha1(#{fingerprint(cert)})"
  end

  def content=(value)
    Puppet.debug("Puppet::Provider::F5_Cert: replacing cetificate #{resource[:name]}")
    transport[wsdl].certificate_import_from_pem(resource[:mode], [resource[:name]], [ resource[:real_content] ], true)
  end

  def create
    transport[wsdl].certificate_import_from_pem(resource[:mode], [resource[:name]], [ resource[:real_content] ], true)
  end

  def destroy
    transport[wsdl].certificate_delete(resource[:mode], [ resource[:name] ])
  end

  def exists?
    lookup(resource[:name])
  end
end
