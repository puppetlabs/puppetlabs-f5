#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_monitor
res_type = Puppet::Type.type(res_type_name)

describe res_type do
  let(:provider) {
    prov = stub 'provider'
    prov.stubs(:name).returns(res_type_name)
    prov
  }
  let(:type) {
    val = res_type
    val.stubs(:defaultprovider).returns provider
    val
  }
  let(:resource) {
    type.new({:name => 'test'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => ["test", "foo"],
      :default => "test", # just to make tests pass
    },
    :is_read_only => {
      :valid => ['true','false'],
      :default => 'false',
    },
    :is_directly_usable => {
      :valid => ['true','false'],
      :default => 'true',
    },
    :manual_resume_state => {
      :valid => [
        'STATE_DISABLED',
        'STATE_ENABLED',
      ],
      :invalid => [
        'something else',
      ],
      :default => nil,
    },
    :parent_template => {
      :default => '',
    },
    :template_destination => {
      :default => ['ATYPE_STAR_ADDRESS_STAR_PORT', '*:*'],
    },
    :template_integer_property => {
      :valid => [
        {'ITYPE_INTERVAL' => 15, 'ITYPE_PROBE_INTERVAL' => 30},
      ],
      :invalid => [
        "foo",
        {'ITYPE_INTERVAL' => 15, 'ITYPE_PROBE_INTERVAL' => 30, "foo" => "bar"},
      ],
      :default => {
        "ITYPE_TIME_UNTIL_UP"=>0,
        "ITYPE_UP_INTERVAL"=>0,
        "ITYPE_PROBE_TIMEOUT"=>0,
        "ITYPE_UNSET"=>0,
        "ITYPE_PROBE_INTERVAL"=>0,
        "ITYPE_INTERVAL"=>5,
        "ITYPE_PROBE_NUM_SUCCESSES"=>0,
        "ITYPE_PROBE_NUM_PROBES"=>0,
        "ITYPE_TIMEOUT"=>16
      },
    },
    :template_state => {
      :valid => [
        "STATE_DISABLED",
        "STATE_ENABLED",
      ],
      :invalid => [
        "something else",
      ],
      :default => nil,
    },
    :template_string_property => {
      :valid => [
        {'STYPE_UNSET' => 15},
      ],
      :invalid => [
        "foo",
        {'foo' => 'bar'},
      ],
      :default => nil,
    },
    :template_type => {
      :valid => [
        "TTYPE_UNSET",
        "TTYPE_POSTGRESQL",
      ],
      :invalid => [
        "something else"
      ],
      :default => nil,
    },
    :template_transparent_mode => {
      :default => nil,
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, :f5_monitor

end
