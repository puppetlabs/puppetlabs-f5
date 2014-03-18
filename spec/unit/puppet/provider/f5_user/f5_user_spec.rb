require 'spec_helper'
require "savon/mock/spec_helper"

describe Puppet::Type.type(:f5_user).provider(:f5_user) do
  include Savon::SpecHelper

  before(:all) {
    message = { folder: "/Common" }
    fixture = File.read("spec/fixtures/f5/management_partition/set_active_folder.xml")
    savon.expects(:set_active_folder).with(message: message).returns(fixture)
  }

  before(:each) {
    savon.mock!

    # Fake url to initialize the device against
    allow(Facter).to receive(:value).with(:feature)
    allow(Facter).to receive(:value).with(:url).and_return("https://admin:admin@f5.puppetlabs.lan/")
  }

  after(:each)  { savon.unmock! }

  let(:f5_user) do
    Puppet::Type.type(:f5_user).new(
      :name            => 'test',
      :password        => { 'is_encrypted' => false, 'password' => 'beep' },
      :login_shell     => '/bin/bash',
      :user_permission => { '[All]' => 'USER_ROLE_ADMINISTRATOR' },
      :description     => 'beep',
      :fullname        => 'test user',
    )
  end

  let(:provider) { f5_user.provider }

  describe '#instances' do
    it do
      # Update this xml file with a real xml response
      get_list_xml = File.read("spec/fixtures/f5/management_partition/get_list.xml")
      savon.expects(:get_list).returns(get_list_xml)
      subject.class.instances
    end
  end

  describe '#create' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_user/create_response.xml')
      message = {:users=>{:item=>[{:user=>{:name=>"test", :full_name=>"test user"}, :password=>{:password=>"beep", :is_encrypted=>false}, :login_shell=>"/bin/bash", :permissions=>[{:item=>{:partition=>"[All]", :role=>"USER_ROLE_ADMINISTRATOR"}}]}]}}
      savon.expects(:create_user_3).with(message: message).returns(fixture)
      provider.create
    end
  end

  describe '#destroy' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_user/destroy_response.xml')
      savon.expects(:delete_user).with(message: { user_names: { item: 'test' }}).returns(fixture)
      provider.destroy
    end
  end

  describe 'exists?' do
    it 'returns false' do
      get_list_xml = File.read("spec/fixtures/f5/management_partition/get_list.xml")
      savon.expects(:get_list).returns(get_list_xml)
      expect(provider.exists?).to be_false
    end
  end

  describe 'user_permission' do
    it 'returns appropriate XML' do
      fixture = File.read('spec/fixtures/f5/f5_user/get_user_permission_response.xml')
      savon.expects(:get_user_permission).with(message: { user_names: { item: ['test'] }}).returns(fixture)
      provider.user_permission
    end
  end

  describe 'user_permission=' do
    it 'returns appropriate XML' do
      fixture = File.read('spec/fixtures/f5/f5_user/set_user_permission_response.xml')
      savon.expects(:set_user_permission).with(message: {:user_names=>{:item=>"test"}, :permissions=>{:item=>[[{:role=>"USER_ROLE_ADMINISTRATOR", :partition=>"[All]"}]]}}).returns(fixture)
      provider.user_permission=({'[All]' => 'USER_ROLE_ADMINISTRATOR'})
    end
  end

  describe 'password' do
    it 'returns encrypted passwords' do
      fixture = File.read('spec/fixtures/f5/f5_user/get_encrypted_password_response.xml')
      savon.expects(:get_encrypted_password).with(message: { user_names: { item: ['test'] }}).returns(fixture)
      provider.password
    end
  end

  describe 'password=' do
    it 'returns appropriate XML' do
      fixture = File.read('spec/fixtures/f5/f5_user/change_password_2_response.xml')
      message = {:user_names=>{:item=>"test"}, :passwords=>{:item=>{:is_encrypted=>false, :password=>"beep"}}}
      savon.expects(:change_password_2).with(message: message).returns(fixture)
      provider.password=({'is_encrypted' => false, 'password' => 'boo'})
    end
  end

  describe 'fullname' do
    it 'returns encrypted passwords' do
      fixture = File.read('spec/fixtures/f5/f5_user/get_fullname_response.xml')
      savon.expects(:get_fullname).with(message: { user_names: { item: ['test'] }}).returns(fixture)
      provider.fullname
    end
  end

  describe 'fullname=' do
    it 'returns appropriate XML' do
      fixture = File.read('spec/fixtures/f5/f5_user/set_fullname_response.xml')
      message = {:user_names=>{:item=>"test"}, fullnames: {item: 'test user'}}
      savon.expects(:set_fullname).with(message: message).returns(fixture)
      provider.fullname=('test user')
    end
  end

  describe 'login_shell' do
    it 'returns encrypted passwords' do
      fixture = File.read('spec/fixtures/f5/f5_user/get_login_shell_response.xml')
      savon.expects(:get_login_shell).with(message: { user_names: { item: ['test'] }}).returns(fixture)
      provider.login_shell
    end
  end

  describe 'login_shell=' do
    it 'returns appropriate XML' do
      fixture = File.read('spec/fixtures/f5/f5_user/set_login_shell_response.xml')
      message = {:user_names=>{:item=>"test"}, :shells=>{:item=>"test user"}}
      savon.expects(:set_login_shell).with(message: message).returns(fixture)
      provider.login_shell=('test user')
    end
  end
end
