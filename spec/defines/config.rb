require 'puppet'
require 'rubygems'
require 'rspec-puppet'

RSpec.configure do |c|
  c.module_path = Puppet[:modulepath]
  c.manifest = File.join(File.dirname(__FILE__), '../site.pp')
end

describe 'f5::config', :type => :define do
  let(:title) { 'f5.puppetlabs.lan' }
  let(:params) {
    { 'password' => 'password',
      'url' => 'f5.puppetlabs.lan',
      'target' => '/etc/puppetlabs/puppet/f5.puppetlabs.lan.conf',
    }
  }

  it 'should generate a configuration file' do
    should contain_file('/etc/puppetlabs/puppet/f5.puppetlabs.lan.conf').with_ensure("present")
    should contain_file('/etc/puppetlabs/puppet/f5.puppetlabs.lan.conf').with_content("[f5.puppetlabs.lan]\ntype f5\nurl https://admin:password@f5.puppetlabs.lan/Common\n")
  end
end

describe 'f5::config', :type => :define do
  let(:title) { 'f5dev.puppetlabs.lan' }
  let(:params) {
    { 'username'  => 'developer',
      'password'  => 'devpwd',
      'url'       => 'f5dev.puppetlabs.lan',
      'partition' => 'dev',
      'target'    => '/etc/puppetlabs/puppet/f5dev.puppetlabs.lan.conf',
    }
  }

  it 'should generate a configuration file' do
    should contain_file('/etc/puppetlabs/puppet/f5dev.puppetlabs.lan.conf').with_ensure("present")
    should contain_file('/etc/puppetlabs/puppet/f5dev.puppetlabs.lan.conf').with_content("[f5dev.puppetlabs.lan]\ntype f5\nurl https://developer:devpwd@f5dev.puppetlabs.lan/dev\n")
  end
end
