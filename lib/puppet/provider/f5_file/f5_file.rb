require 'puppet/provider/f5'

Puppet::Type.type(:f5_file).provide(:f5_file, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 String classes (datagroups)"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.Class'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    # We will not attempt to retrieve a list of all files on the system.
    return []
  end

  def content
    return "md5(#{@md5_checksum})"
  end

  def content=(value)
    Puppet.debug("Puppet::Provider::F5_file: updating file #{resource[:name]}")
    upload_file(resource[:name], resource[:real_content])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_file: creating file #{resource[:name]}")
    upload_file(resource[:name], resource[:real_content])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_file: deleting file #{resource[:name]}")
    delete_file(resource[:name])
  end

  def exists?
    begin
      @file = download_file(resource[:name])
      @md5_checksum = Digest::MD5.hexdigest(@file)
      return true
    rescue SOAP::FaultError => e
      Puppet.debug("Puppet::Provider::F5_file: file #{resource[:name]} does not exist")
      return false
    end
  end
end
