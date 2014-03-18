require 'spec_helper'
require 'puppet/provider/f5'
require 'ostruct'

describe Puppet::Provider::F5 do

  let(:f5_prov_obj) { Puppet::Provider::F5.new }

  number_tests = [
    {:'32' => "1234",
     :'64' => {:high => 0x0, :low => 0x4D2}},
    {:'32' => "555896254785628",
     :'64' => {:high => 0x1F995, :low => 0xAECC685C}},
  ]

  describe "to_32h method" do
    number_tests.each do |entry|
      it "should convert #{entry[:'32']} to #{entry[:'64'].inspect}" do
        f5_prov_obj.to_32h(entry[:'32']).should == entry[:'64']
      end
    end
  end

  describe "to_64s method" do
    number_tests.each do |entry|
      # Using an OpenStruct as the SOAP request returns an object with methods
      # not the hash as returned by to_32h
      ostruct = OpenStruct.new(entry[:'64'])
      it "should convert #{ostruct.inspect} to #{entry[:'32']}" do
        f5_prov_obj.to_64s(ostruct).should == entry[:'32']
      end
    end
  end

  network_tests = [
    {:full => "192.168.4.1:1234",
     :address => "192.168.4.1",
     :port => "1234",},
    {:full => "3.2.1.4:22",
     :address => "3.2.1.4",
     :port => "22",},
    {:full => "1234::1:123",
     :address => "1234::1",
     :port => "123",},
    {:full => "1.1.1.1:*",
     :address => "1.1.1.1",
     :port => "*",},
  ]

  describe "network_address method" do
    network_tests.each do |entry|
      it "should get #{entry[:address]} from #{entry[:full]}" do
        f5_prov_obj.network_address(entry[:full]).should == entry[:address]
      end
    end
  end

  describe "network_port method" do
    network_tests.each do |entry|
      it "should get #{entry[:address]} from #{entry[:full]}" do
        f5_prov_obj.network_port(entry[:full]).should == entry[:port]
      end
    end
  end

  describe "transport method" do
    it "with uninitialized device and no url should return error" do
      expect { f5_prov_obj.transport }.to(
        raise_error(Puppet::Error, /device not initialized/)
      )
    end

    it "with uninitialized device and a unresolvable url should return error" do
      Facter.expects(:value).with(:url).twice.returns("https://myuser:mypass@mockurl/")
      expect { f5_prov_obj.transport }.to(
        raise_error(SocketError, /^getaddrinfo: nodename nor servname provided, or not known/)
      )
    end

  end
end
