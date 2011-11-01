#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_rule
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
    :definition => {
      :default => nil,
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

end
