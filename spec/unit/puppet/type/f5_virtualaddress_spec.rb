#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_virtualaddress
res_type = Puppet::Type.type(res_type_name)

describe res_type do
  let(:provider) {
    prov = stub 'provider'
    prov.stubs(:name).returns(res_type_name)
    prov
  }
  let(:res_type) {
    type = res_type
    type.stubs(:defaultprovider).returns provider
    type
  }
  let(:resource) {
    res_type.new({:name => '192.0.2.1'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => ["192.0.2.1"],
      :default => "192.0.2.1", # just to make tests pass
    },
    :connection_limit => {
      :valid => [
        "1",
        "1000",
      ],
      :invalid => [
        "foo",
      ],
      :default => nil,
    },
    :arp_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "foo",
      ],
      :default => nil,
    },
    :enabled_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "foo",
      ],
      :default => nil,
    },
    :is_floating_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "foo",
      ],
      :default => nil,
    },
    :route_advertisement_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "foo",
      ],
      :default => nil,
    },
    :status_dependency_scope => {
      :valid => [
        "VIRTUAL_ADDRESS_STATUS_DEPENDENCY_NONE",
        "VIRTUAL_ADDRESS_STATUS_DEPENDENCY_ANY",
        "VIRTUAL_ADDRESS_STATUS_DEPENDENCY_ALL"
      ],
      :invalid => [
        "foo",
      ],
      :default => nil,
    }
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

end
