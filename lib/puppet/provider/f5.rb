require 'puppet/util/network_device/f5/device'

class Puppet::Provider::F5 < Puppet::Provider

  def self.transport(url='https://admin:admin@f5.puppetlabs.lan/')
    @transport ||= Puppet::Util::NetworkDevice::F5::Device.new(url).transport
  end

  def transport
    # this calls the class instance of self.transport instead of the object instance which causes an infinite loop.
    self.class.transport
  end
end
