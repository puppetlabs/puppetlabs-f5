#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_user
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
    res_type.new({:name => 'testuser'})
  }

  it 'should have :name be its namevar' do
    res_type.key_attributes.should == [:name]
  end

  # This is just a simpler way of providing basic validation tests
  # for people not familiar with rspec.
  parameter_tests = {
    :name => {
      :valid => ["testuser", "account"],
      :default => "test", # just to make tests pass
    },
    :password => {
      :valid => [ {'password' => '$1$abcdef$TSUZRW2CK3aUh/W8JXyHF/', 'is_encrypted' => true} ],
      :invalid => [ {'password' => '$1$abcdef$TSUZRW2CK3aUh/W8JXyHF/', 'is_encrypted' => 'meh'} ],
      :default => nil,
    },
    :user_permission  => {
      :valid => [ { '[All]' => 'USER_ROLE_ADMINISTRATOR' } ],
      :invalid => [ "something else" ],
      :default => nil,
    },
    :login_shell => {
      :valid => [ "/bin/sh", "/bin/bash" ],
      :default => nil,
    },
    :full_name => {
      :valid => [ "Some test user", "Some account" ],
      :default => nil,
    },
  }
  it_should_behave_like "a puppet type", parameter_tests, res_type_name

end
