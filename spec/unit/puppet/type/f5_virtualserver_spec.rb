#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_virtualserver
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
    res_type.new({:name => 'test_node'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => ["test_node", "test node"],
      :default => "test", # just to make tests pass
    },
    :clone_pool => {
      :default => nil,
    },
    :cmp_enabled_state => {
      :valid => [
        "STATE_ENABLED",
        "STATE_DISABLED",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :connection_limit => {
      :valid => [
        "5",
        "10",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :connection_mirror_state => {
      :valid => [
        "STATE_ENABLED",
        "STATE_DISABLED",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :default_pool_name => {
      :default => nil,
    },
    :destination => {
      :default => nil,
    },
    :enabled_state => {
      :default => nil,
    },
    :fallback_persistence_profile => {
      :default => nil,
    },
    :gtm_score => {
      :default => nil,
    },
    :last_hop_pool => {
      :default => nil,
    },
    :nat64_state => {
      :valid => [
        "STATE_ENABLED",
        "STATE_DISABLED",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :protocol => {
      :valid => [
        "PROTOCOL_ANY",
        "PROTOCOL_IPV6",
        "PROTOCOL_ROUTING",
        "PROTOCOL_NONE",
        "PROTOCOL_FRAGMENT",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :rate_class => {
      :default => nil,
    },
    :persistence_profile => {
      :default => nil,
    },
    :profile => {
      :default => nil,
    },
    :rule => {
      :default => nil,
    },
    :snat_type => {
      :valid => [
        "SNAT_TYPE_NONE",
        "SNAT_TYPE_TRANSLATION_ADDRESS",
        "SNAT_TYPE_SNATPOOL",
        "SNAT_TYPE_AUTOMAP",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :snat_pool => {
      :default => nil,
    },
    :source_port_behavior => {
      :valid => [
        "SOURCE_PORT_PRESERVE",
        "SOURCE_PORT_PRESERVE_STRICT",
        "SOURCE_PORT_CHANGE",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :translate_address_state => {
      :valid => [
        "STATE_ENABLED",
        "STATE_DISABLED",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :translate_port_state => {
      :valid => [
        "STATE_ENABLED",
        "STATE_DISABLED",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :type => {
      :valid => [
        "RESOURCE_TYPE_POOL",
        "RESOURCE_TYPE_IP_FORWARDING",
        "RESOURCE_TYPE_L2_FORWARDING",
        "RESOURCE_TYPE_REJECT",
        "RESOURCE_TYPE_FAST_L4",
        "RESOURCE_TYPE_FAST_HTTP",
        "RESOURCE_TYPE_STATELESS",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :vlan => {
      :valid => [
        {"state" => "something?", "vlans"=>["1","2","3"]},
      ],
      :invalid => [
        "not a hash",
        {"state" => "something?", "somekey" => "bleah" },
      ],
      :default => nil,
    },
    :wildmask => {
      :default => nil,
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

end
