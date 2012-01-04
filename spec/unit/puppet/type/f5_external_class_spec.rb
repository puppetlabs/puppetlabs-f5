#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_external_class
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
      :valid   => ['test_node', 'test node'],
      :default => 'test', # just to make tests pass
    },
    :file_format => {
      :valid   => ['FILE_FORMAT_UNKNOWN', 'FILE_FORMAT_CSV'],
      :invalid => ['FILE_FORMAT_TXT'],
      :default => 'FILE_FORMAT_CSV',
    },
    :file_mode => {
      :valid   => ['FILE_MODE_UNKNOWN', 'FILE_MODE_TYPE_READ', 'FILE_MODE_TYPE_READ_WRITE'],
      :invalid => ['FILE_MODE_WRITE'],
      :default => 'FILE_MODE_TYPE_READ_WRITE',
    },
    :file_name => {
      :valid   => ['/config/file.txt', '/file.txt'],
    },
    :data_separator => {
      :valid   => [':=', '|', ' '],
      :invalid => ['a'],
      :default => ':=',
    },
    :type => {
      :valid   => ['CLASS_TYPE_UNDEFINED', 'CLASS_TYPE_ADDRESS', 'CLASS_TYPE_STRING', 'CLASS_TYPE_VALUE'],
      :invalid => ['CLASS_TYPE_DATA'],
    }
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

end
