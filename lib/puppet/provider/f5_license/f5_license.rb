require 'puppet/provider/f5'
require "base64"

Puppet::Type.type(:f5_license).provide(:f5_license, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 license"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Management.LicenseAdministration'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    [new(:name => 'license')]
  end

  def license_file_data
    if transport[wsdl].get_license_activation_status == 'STATE_ENABLED'
      l=transport[wsdl].get_license_file().first
      "md5(#{Digest::MD5.hexdigest(Base64.decode64(l))})"
    else
      "NO_LICENCE_ACTIVATED"
    end
  end
  
  def license_file_data=(value)
    transport[wsdl].install_license(resource[:license_file_content])
  end
end
