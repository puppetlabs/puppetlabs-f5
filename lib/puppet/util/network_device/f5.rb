require 'openssl'
require 'digest/sha1'

module Puppet::Util::NetworkDevice::F5
  # This is intended to decode certificate (subject, serial, issuer, expiration) for comparison.
  def self.decode(content)
    cert = case content.split("\n").first
           when /BEGIN X509 CRL/
             OpenSSL::X509::CRL
           when /BEGIN CERTIFICATE REQUEST/
             OpenSSL::X509::Request
           when /BEGIN CERTIFICATE/
             OpenSSL::X509::Certificate
           when /BEGIN RSA (PRIVATE|PUBLIC) KEY/
             OpenSSL::PKey::RSA
           when /BEGIN DSA (PRIVATE|PUBLIC) KEY/
             OpenSSL::Pkey::DSA
           else return nil
           end
    cert.new(content)
  rescue Exception => e
    raise Puppet::Error, "Puppet::Provider::F5_Cert: failed to decode certificate content. Error: #{e.message}\n#{content}"
  end

  # Calculate cert fingerprint
  def self.fingerprint(content)
    cert = decode(content)
    Digest::SHA1.hexdigest(cert.to_der)
  end
end
