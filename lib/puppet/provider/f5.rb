require 'puppet/util/network_device/f5/device'

class Puppet::Provider::F5 < Puppet::Provider

  attr_accessor :device

  # convert 64bit Integer to F5 representation as {:high => 32bit, :low => 32bit}
  def to_32h(value)
    high = (value.to_i & 0xFFFFFFFF00000000) >> 32
    low  = value.to_i & 0xFFFFFFFF
    {:high => high, :low => low}
  end

  # convert F5 representation of 64 bit to string (since Puppet compares string rather than int)
  def to_64s(value)
    ((value.high.to_i << 32) + value.low.to_i).to_s
  end

  def network_address(value)
    value.split(':')[0]
  end

  def network_port(value)
    port = value.split(':')[1]
    port.to_i unless port == '*'
    port
  end

  def self.transport
    if Facter.value(:url) then
      Puppet.debug "Puppet::Util::NetworkDevice::F5: connecting via facter url."
      @device ||= Puppet::Util::NetworkDevice::F5::Device.new(Facter.value(:url))
    else
      @device ||= Puppet::Util::NetworkDevice.current
      raise Puppet::Error, "Pupet::Util::NetworkDevice::F5: device not initialized." unless @device
    end
    @tranport = @device.transport
  end

  def transport
    # this calls the class instance of self.transport instead of the object instance which causes an infinite loop.
    self.class.transport
  end
end
