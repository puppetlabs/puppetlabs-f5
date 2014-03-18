require 'spec_helper'
require "savon/mock/spec_helper"

describe Puppet::Type.type(:f5_rule).provider(:f5_rule) do
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

  let(:f5_rule) do
    Puppet::Type.type(:f5_rule).new(
      :name       => '/Common/test',
      :ensure     => :present,
      :definition => 'when HTTP_REQUEST {}',
    )
  end

  let(:provider) { f5_rule.provider }

  describe '#instances' do
    it 'returns appropriate XML' do
      get_list_xml = File.read("spec/fixtures/f5/f5_rule/get_list_response.xml")
      savon.expects(:get_list).returns(get_list_xml)
      subject.class.instances
    end
  end

  describe '#create' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_rule/create_response.xml')
      message = {:rules=>{:item=>{"rule_name"=>"/Common/test", "rule_definition"=>"when HTTP_REQUEST {}"}}}
      savon.expects(:create).with(message: message).returns(fixture)
      provider.create
    end
  end

  describe '#destroy' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_rule/delete_rule_response.xml')
      message = {:rule_names=>{:item=>"/Common/test"}}
      savon.expects(:delete_rule).with(message: message).returns(fixture)
      provider.destroy
    end
  end

  describe '#exists?' do
    it 'returns false' do
      get_list_xml = File.read("spec/fixtures/f5/f5_rule/get_list_response.xml")
      savon.expects(:get_list).returns(get_list_xml)
      expect(provider.exists?).to be_false
    end
  end

  describe '#definition' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_rule/query_rule_response.xml')
      message = {:rule_names=>{:item=>"/Common/test"}}
      savon.expects(:query_rule).with(message: message).returns(fixture)
      provider.definition
    end
  end

  describe '#definition=' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_rule/modify_rule_response.xml')
      message = {:rules=>{:item=>{"rule_name"=>"/Common/test", "rule_definition"=>"test"}}}
      savon.expects(:modify_rule).with(message: message).returns(fixture)
      provider.definition=('test')
    end
  end

end
