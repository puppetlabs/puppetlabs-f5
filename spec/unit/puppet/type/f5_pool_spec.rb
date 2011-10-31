#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_pool
res_type = Puppet::Type.type(res_type_name)

describe res_type do
  let(:provider) {
    prov = stub 'provider'
    prov.stubs(:name).returns(res_type_name)
    prov
  }
  let(:type) {
    type = res_type
    type.stubs(:defaultprovider).returns provider
    type
  }
  let(:resource) {
    type.new({:name => 'test_pool'})
  }

  it 'should have :name be its namevar' do
    type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => ["test_pool", "test pool"],
      :default => "test", # just to make tests pass
    },
    :action_on_service_down => {
      :valid => [
        "SERVICE_DOWN_ACTION_NONE",
        "SERVICE_DOWN_ACTION_RESET",
        "SERVICE_DOWN_ACTION_DROP",
        "SERVICE_DOWN_ACTION_RESELECT",
      ],
      :invalid => [
        "foobar",
        "SERVICE_DOWN_ACTION_NONE_foobar",
      ],
      :default => nil,
    },
    :allow_nat_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :allow_snat_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :client_ip_tos => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :client_link_qos => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :gateway_failsafe_device => {
      :default => nil,
    },
    :gateway_failsafe_unit_id => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :lb_method => {
      :valid => [
        "LB_METHOD_ROUND_ROBIN",
        "LB_METHOD_RATIO_MEMBER",
        "LB_METHOD_LEAST_CONNECTION_MEMBER",
        "LB_METHOD_OBSERVED_MEMBER",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :member => {
      :default => nil,
    },
    :membership => {
      :default => :inclusive,
    },
    :minimum_active_member => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :minimum_up_member => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :minimum_up_member_action => {
      :default => nil,
    },
    :minimum_up_member_enabled_state => {
      :default => nil,
    },
    :monitor_association => {
      :valid => [
        {'monitor_templates' => [], 'quorum' => 0, 'type' => 'MONITOR_RULE_TYPE_AND_LIST'},
      ],
      :invalid => [
        {},
        "foobar",
        {'monitor_templates' => [], 'quorum' => 0},
        {'monitor_templates' => [], 'quorum' => 0, 'invalid_key' => 'bleah'},
      ],
      :default => nil,
    },
    :server_ip_tos => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :server_link_qos => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :simple_timeout => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
    :slow_ramp_time => {
      :valid => [
        "15",
        "1024",
      ],
      :invalid => [
        "foobar",
      ],
      :default => nil,
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, :f5_pool

  it "parameter monitor_association, key monitor_templates should always be converted to an array" do
    resource[:monitor_association] = { 'monitor_templates' => "foo",
      'quorum' => '0', 'type' => 'MONITOR_RULE_TYPE_AND_LIST' }
    resource[:monitor_association].should == { 'monitor_templates' => ["foo"],
      'quorum' => '0', 'type' => 'MONITOR_RULE_TYPE_AND_LIST' } 
  end

end
