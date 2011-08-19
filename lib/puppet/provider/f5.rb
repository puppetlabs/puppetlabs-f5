require 'puppet/util/network_device/f5/device'

class Puppet::Provider::F5 < Puppet::Provider

  attr_accessor :device

  def self.transport
    # TODO: support Facter url to simplify testing. this will be removed in the final release.
    url= Facter.url ? Facter.url : 'https://admin:admin@f5.puppetlabs.lan/'

    @device ||= Puppet::Util::NetworkDevice.current ? Puppet::Util::NetworkDevice.current : Puppet::Util::NetworkDevice::F5::Device.new(url)
    @tranport = @device.transport
  end

  def transport
    # this calls the class instance of self.transport instead of the object instance which causes an infinite loop.
    self.class.transport
  end
end
