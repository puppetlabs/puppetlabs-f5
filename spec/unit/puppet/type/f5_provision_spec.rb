#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_provision
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
    res_type.new({:name => 'TMOS_MODULE_LTM'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => [
        'TMOS_MODULE_ASM',
        'TMOS_MODULE_SAM',
        'TMOS_MODULE_WAM',
        'TMOS_MODULE_PSM',
        'TMOS_MODULE_WOM',
        'TMOS_MODULE_LC',
        'TMOS_MODULE_LTM',
        'TMOS_MODULE_GTM',
        'TMOS_MODULE_WOML',
        'TMOS_MODULE_EM',
        'TMOS_MODULE_VCMP',
        'TMOS_MODULE_TMOS',
        'TMOS_MODULE_HOST',
        'TMOS_MODULE_UI',
        'TMOS_MODULE_MONITORS',
        'TMOS_MODULE_AVR',
      ],
      :invalid => [ 'TMOS_MODULE_FOO' ],
      :default => 'TMOS_MODULE_LTM', # just to make tests pass
    },
    :custom_cpu_ratio=> {
      :valid => [ 0, 10, 255 ],
      :invalid => [ 'something else' ],
      :default => 0,
    },
    :custom_disk_ratio=> {
      :valid => [ 0, 10, 255 ],
      :invalid => [ 'something else' ],
      :default => 0,
    },
    :custom_memory_ratio=> {
      :valid => [ 0, 10, 255 ],
      :invalid => [ 'something else' ],
      :default => 0,
    },
    :level => {
      :valid => [
        'PROVISION_LEVEL_NONE',
        'PROVISION_LEVEL_MINIMUM',
        'PROVISION_LEVEL_NOMINAL',
        'PROVISION_LEVEL_DEDICATED',
        'PROVISION_LEVEL_CUSTOM',
      ],
      :invalid => ['vlan1'],
      :default => nil,
    },
  }
  require 'ruby-debug'
  Debugger.start
#  debugger
  it_should_behave_like 'a puppet type', parameter_tests, res_type_name

end
