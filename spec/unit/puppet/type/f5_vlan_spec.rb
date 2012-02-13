#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_vlan
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
    res_type.new({:name => 'test_vlan'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => ['test_node', 'test node'],
      :default => 'test', # just to make tests pass
    },
    :failsafe_action=> {
      :valid => [
        'HA_ACTION_NONE',
        'HA_ACTION_RESTART_ALL',
      ],
      :invalid => [ 'something else' ],
      :default => nil,
    },
    :failsafe_state => {
      :valid => [
        'STATE_ENABLED',
        'STATE_DISABLED',
      ],
      :invalid => [ 'something else' ],
      :default => nil,
    },
    :failsafe_timeout => {
      :valid => [1000, 4000],
      :invalid => ['vlan1'],
      :default => nil,
    },
    :learning_mode => {
      :valid => [
        'LEARNING_MODE_ENABLE_FORWARD',
        'LEARNING_MODE_DISABLE_FORWARD',
        'LEARNING_MODE_DISABLE_DROP',
      ],
      :invalid => ['vlan1'],
      :default => nil,
    },
    :mac_masquerade_address => {
      :default => nil,
    },
    :member => {
      :valid => [ [] ],
      :default => nil,
    },
    :mtu => {
      :valid => [1000, 1500],
      :invalid => ['vlan1'],
      :default => nil,
    },
    :source_check_state => {
      :valid => [
        'STATE_ENABLED',
        'STATE_DISABLED',
      ],
      :invalid => [ 'something else' ],
      :default => nil,
    },
    :static_forwarding => {
      :valid => [ [] ],
      :default => nil,
    },
    :vlan_id => {
      :valid => [1, 4095],
      :invalid => ['vlan1'],
      :default => nil,
    },
  }
  it_should_behave_like 'a puppet type', parameter_tests, res_type_name

end
