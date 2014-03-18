require 'spec_helper'
require "savon/mock/spec_helper"

describe Puppet::Type.type(:f5_certificate).provider(:f5_certificate) do
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

  let(:f5_certificate) do
    Puppet::Type.type(:f5_certificate).new(
      :name    => '/Common/default',
      :ensure  => :present,
      :mode    => 'MANAGEMENT_MODE_DEFAULT',
      :content => '-----BEGIN CERTIFICATE-----
MIIFUTCCAzmgAwIBAgIBAzANBgkqhkiG9w0BAQsFADAgMR4wHAYDVQQDDBVQdXBw
ZXQgQ0E6IHZhZ3JhbnQudm0wHhcNMTQwMzE5MjExNTA1WhcNMTkwMzE5MjExNTA1
WjAcMRowGAYDVQQDDBFmNS5wdXBwZXRsYWJzLmxhbjCCAiIwDQYJKoZIhvcNAQEB
BQADggIPADCCAgoCggIBALNjHR0iohM/vMNRhn9DnuREp+9qmt4GTf4yl4EulX7x
99NNnG9z5TBNKCLUerh8aLa3/8BobkpA85U7K2RQXYLcKENRsk2sHWQ0GUw+0Q45
2GPXe5prVwzzAVqqpx8ldtsXrqWPPz/RnCZwwhNseNfZoMbC/HNTTs1JTGbEurPe
yp+m80e06vK3O2EpMbkagudSHGJ6muGrdC3GqVDUUa1WHVpbBfHiuUdFdxG+ZB9/
xFPxbw+Jku7rEadg5z8/bj0HJuqgotidsr4N2J+lp142lchsZWp499YMYJ+g3WLY
x1yq+feTKGRI/YhmtdmaaiQYQcjD8/dsYTKX7zDa0vQCXRrvAgWgMqyocDjvJApZ
JeH1+0713T8o/UhhHB+heFrNv9rSpX/7ww6mGJA9fuU5WAOD8bGf5Yp0ZmHZumLZ
KamTHHby6A23Ht2wkUsVjMufEVtBelYu/FF5nQN/eJ6vBuckN7yX2zwHRxz/3pRe
KFPYeqIi0rIXc2uzHjC6Dy/Y7MGPTttBzxkKI4KzRmXLgcOBV1KUdxvizvLP3bUx
PSx/YwQGj9sjuCXrxulX+sBLdJ962s7b0E8jwpRgUZUmNLjFplUA69FosqROVQzo
+AUvdX7pGTKu+jPbwCWjIp+hqCRid5ti97JoIUO3+AxtT6FsoJDHCmWWGyEoWBZx
AgMBAAGjgZkwgZYwNQYJYIZIAYb4QgENBChQdXBwZXQgUnVieS9PcGVuU1NMIElu
dGVybmFsIENlcnRpZmljYXRlMA4GA1UdDwEB/wQEAwIFoDAgBgNVHSUBAf8EFjAU
BggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUUUiZ
mQEtkpSAGtVOOsCmct1b7q0wDQYJKoZIhvcNAQELBQADggIBACoNVWJw4gf4yH2L
1sy2qYWXat46ne56+ovPLVb53xiiHwGcMT2tSDKECAnctikvQEExLlzqs0+JQy5E
mj7kzVnBCaxZHjRVbq7KkxA+F/oBkHqdaJSQ1pslZm8HdMfaaQVyqWJDzNFAuGoP
J9/ZwG8HA3wzTWJQ3Ryt8chH1A7SppO5k941O/N+XDOzHznMqNqZUMtTgs+53Svn
h7MyA51NyBxPbB5yhOpulX7knFj9wd4vI9z53zZ3T8IgFwOoprGsJXBpgLtPFqt1
8McUB8j4bEtiFz3Nal3MzrxUrHbW5k31+JtDeoCnI8QF19kB5uwRF8lfje2+qsvx
7MfsqCGGe3ra8X6oOj0QbitbwLjdKI2+ry44fih38A+7brmRvM78bAXoZw2qwO4G
8uHJ/s4LP+U7o9XeFoNJ9g2uZrtx1922Ub7QZit4+tK+czTRTBXOv0miZY8qN8YR
9GZyw6XmTv63xJDrZ6LkYNCWaeM0tcmuNDthEs+gLIjy61Atpl/BZwUv5uard4vV
3L+o/YmMmyfj2GB1ts9fk2anQgQPl8ZwVLTLNkNIm+wTTIsu33FLIW8HKAdL0/Iz
0Y1bNcWcsmO2c8DC2q760umvP5AuAvb7uz3Lek5FDR0uk9Ug3/Dz7sxyNBcCo4tl
lIAFvHt4a0qXRDum5FzFxythgUPZ
-----END CERTIFICATE-----',
    )
  end

  let(:provider) { f5_certificate.provider }
  let(:instance) { provider.class.instances.first }

  describe '#instances' do
    it 'returns appropriate XML' do
      fixture = File.read("spec/fixtures/f5/f5_certificate/get_certificate_list_response.xml")
      savon.expects(:get_certificate_list).with(message: {mode: 'MANAGEMENT_MODE_DEFAULT'}).returns(fixture)
      expect(subject.class.instances.count).to eq(3)
    end
  end

  describe '#create' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_certificate/certificate_create_response.xml')
      # This is.. not pretty.
      message = {:mode=>"MANAGEMENT_MODE_DEFAULT", :cert_ids=>{:item=>"/Common/default"}, :pem_data=>{:item=>"-----BEGIN CERTIFICATE-----\nMIIFUTCCAzmgAwIBAgIBAzANBgkqhkiG9w0BAQsFADAgMR4wHAYDVQQDDBVQdXBw\nZXQgQ0E6IHZhZ3JhbnQudm0wHhcNMTQwMzE5MjExNTA1WhcNMTkwMzE5MjExNTA1\nWjAcMRowGAYDVQQDDBFmNS5wdXBwZXRsYWJzLmxhbjCCAiIwDQYJKoZIhvcNAQEB\nBQADggIPADCCAgoCggIBALNjHR0iohM/vMNRhn9DnuREp+9qmt4GTf4yl4EulX7x\n99NNnG9z5TBNKCLUerh8aLa3/8BobkpA85U7K2RQXYLcKENRsk2sHWQ0GUw+0Q45\n2GPXe5prVwzzAVqqpx8ldtsXrqWPPz/RnCZwwhNseNfZoMbC/HNTTs1JTGbEurPe\nyp+m80e06vK3O2EpMbkagudSHGJ6muGrdC3GqVDUUa1WHVpbBfHiuUdFdxG+ZB9/\nxFPxbw+Jku7rEadg5z8/bj0HJuqgotidsr4N2J+lp142lchsZWp499YMYJ+g3WLY\nx1yq+feTKGRI/YhmtdmaaiQYQcjD8/dsYTKX7zDa0vQCXRrvAgWgMqyocDjvJApZ\nJeH1+0713T8o/UhhHB+heFrNv9rSpX/7ww6mGJA9fuU5WAOD8bGf5Yp0ZmHZumLZ\nKamTHHby6A23Ht2wkUsVjMufEVtBelYu/FF5nQN/eJ6vBuckN7yX2zwHRxz/3pRe\nKFPYeqIi0rIXc2uzHjC6Dy/Y7MGPTttBzxkKI4KzRmXLgcOBV1KUdxvizvLP3bUx\nPSx/YwQGj9sjuCXrxulX+sBLdJ962s7b0E8jwpRgUZUmNLjFplUA69FosqROVQzo\n+AUvdX7pGTKu+jPbwCWjIp+hqCRid5ti97JoIUO3+AxtT6FsoJDHCmWWGyEoWBZx\nAgMBAAGjgZkwgZYwNQYJYIZIAYb4QgENBChQdXBwZXQgUnVieS9PcGVuU1NMIElu\ndGVybmFsIENlcnRpZmljYXRlMA4GA1UdDwEB/wQEAwIFoDAgBgNVHSUBAf8EFjAU\nBggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUUUiZ\nmQEtkpSAGtVOOsCmct1b7q0wDQYJKoZIhvcNAQELBQADggIBACoNVWJw4gf4yH2L\n1sy2qYWXat46ne56+ovPLVb53xiiHwGcMT2tSDKECAnctikvQEExLlzqs0+JQy5E\nmj7kzVnBCaxZHjRVbq7KkxA+F/oBkHqdaJSQ1pslZm8HdMfaaQVyqWJDzNFAuGoP\nJ9/ZwG8HA3wzTWJQ3Ryt8chH1A7SppO5k941O/N+XDOzHznMqNqZUMtTgs+53Svn\nh7MyA51NyBxPbB5yhOpulX7knFj9wd4vI9z53zZ3T8IgFwOoprGsJXBpgLtPFqt1\n8McUB8j4bEtiFz3Nal3MzrxUrHbW5k31+JtDeoCnI8QF19kB5uwRF8lfje2+qsvx\n7MfsqCGGe3ra8X6oOj0QbitbwLjdKI2+ry44fih38A+7brmRvM78bAXoZw2qwO4G\n8uHJ/s4LP+U7o9XeFoNJ9g2uZrtx1922Ub7QZit4+tK+czTRTBXOv0miZY8qN8YR\n9GZyw6XmTv63xJDrZ6LkYNCWaeM0tcmuNDthEs+gLIjy61Atpl/BZwUv5uard4vV\n3L+o/YmMmyfj2GB1ts9fk2anQgQPl8ZwVLTLNkNIm+wTTIsu33FLIW8HKAdL0/Iz\n0Y1bNcWcsmO2c8DC2q760umvP5AuAvb7uz3Lek5FDR0uk9Ug3/Dz7sxyNBcCo4tl\nlIAFvHt4a0qXRDum5FzFxythgUPZ\n-----END CERTIFICATE-----"}, :overwrite=>true}
      savon.expects(:certificate_import_from_pem).with(message: message).returns(fixture)
      provider.create
    end
  end

  describe '#destroy' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_certificate/certificate_delete_response.xml')
      message = {:mode=>"MANAGEMENT_MODE_DEFAULT", :cert_ids=>{:item=>"/Common/default"}}
      savon.expects(:certificate_delete).with(message: message).returns(fixture)
      provider.destroy
    end
  end

  describe '#exists?' do
    it 'returns true' do
      fixture = File.read("spec/fixtures/f5/f5_certificate/get_certificate_list_response.xml")
      savon.expects(:get_certificate_list).with(message: {mode: 'MANAGEMENT_MODE_DEFAULT'}).returns(fixture)
      expect(instance.exists?).to be_true
    end
  end

  describe '#content' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_certificate/certificate_export_to_pem_response.xml')
      message = {}
      savon.expects(:certificate_export_to_pem).with(message: message).returns(fixture)
      provider.content
    end
  end

  describe '#content=' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_certificate/certificate_create_response.xml')
      message = {:mode=>"MANAGEMENT_MODE_DEFAULT", :cert_ids=>{:item=>"/Common/default"}, :pem_data=>{:item=>"-----BEGIN CERTIFICATE-----\nMIIFUTCCAzmgAwIBAgIBAzANBgkqhkiG9w0BAQsFADAgMR4wHAYDVQQDDBVQdXBw\nZXQgQ0E6IHZhZ3JhbnQudm0wHhcNMTQwMzE5MjExNTA1WhcNMTkwMzE5MjExNTA1\nWjAcMRowGAYDVQQDDBFmNS5wdXBwZXRsYWJzLmxhbjCCAiIwDQYJKoZIhvcNAQEB\nBQADggIPADCCAgoCggIBALNjHR0iohM/vMNRhn9DnuREp+9qmt4GTf4yl4EulX7x\n99NNnG9z5TBNKCLUerh8aLa3/8BobkpA85U7K2RQXYLcKENRsk2sHWQ0GUw+0Q45\n2GPXe5prVwzzAVqqpx8ldtsXrqWPPz/RnCZwwhNseNfZoMbC/HNTTs1JTGbEurPe\nyp+m80e06vK3O2EpMbkagudSHGJ6muGrdC3GqVDUUa1WHVpbBfHiuUdFdxG+ZB9/\nxFPxbw+Jku7rEadg5z8/bj0HJuqgotidsr4N2J+lp142lchsZWp499YMYJ+g3WLY\nx1yq+feTKGRI/YhmtdmaaiQYQcjD8/dsYTKX7zDa0vQCXRrvAgWgMqyocDjvJApZ\nJeH1+0713T8o/UhhHB+heFrNv9rSpX/7ww6mGJA9fuU5WAOD8bGf5Yp0ZmHZumLZ\nKamTHHby6A23Ht2wkUsVjMufEVtBelYu/FF5nQN/eJ6vBuckN7yX2zwHRxz/3pRe\nKFPYeqIi0rIXc2uzHjC6Dy/Y7MGPTttBzxkKI4KzRmXLgcOBV1KUdxvizvLP3bUx\nPSx/YwQGj9sjuCXrxulX+sBLdJ962s7b0E8jwpRgUZUmNLjFplUA69FosqROVQzo\n+AUvdX7pGTKu+jPbwCWjIp+hqCRid5ti97JoIUO3+AxtT6FsoJDHCmWWGyEoWBZx\nAgMBAAGjgZkwgZYwNQYJYIZIAYb4QgENBChQdXBwZXQgUnVieS9PcGVuU1NMIElu\ndGVybmFsIENlcnRpZmljYXRlMA4GA1UdDwEB/wQEAwIFoDAgBgNVHSUBAf8EFjAU\nBggrBgEFBQcDAQYIKwYBBQUHAwIwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQUUUiZ\nmQEtkpSAGtVOOsCmct1b7q0wDQYJKoZIhvcNAQELBQADggIBACoNVWJw4gf4yH2L\n1sy2qYWXat46ne56+ovPLVb53xiiHwGcMT2tSDKECAnctikvQEExLlzqs0+JQy5E\nmj7kzVnBCaxZHjRVbq7KkxA+F/oBkHqdaJSQ1pslZm8HdMfaaQVyqWJDzNFAuGoP\nJ9/ZwG8HA3wzTWJQ3Ryt8chH1A7SppO5k941O/N+XDOzHznMqNqZUMtTgs+53Svn\nh7MyA51NyBxPbB5yhOpulX7knFj9wd4vI9z53zZ3T8IgFwOoprGsJXBpgLtPFqt1\n8McUB8j4bEtiFz3Nal3MzrxUrHbW5k31+JtDeoCnI8QF19kB5uwRF8lfje2+qsvx\n7MfsqCGGe3ra8X6oOj0QbitbwLjdKI2+ry44fih38A+7brmRvM78bAXoZw2qwO4G\n8uHJ/s4LP+U7o9XeFoNJ9g2uZrtx1922Ub7QZit4+tK+czTRTBXOv0miZY8qN8YR\n9GZyw6XmTv63xJDrZ6LkYNCWaeM0tcmuNDthEs+gLIjy61Atpl/BZwUv5uard4vV\n3L+o/YmMmyfj2GB1ts9fk2anQgQPl8ZwVLTLNkNIm+wTTIsu33FLIW8HKAdL0/Iz\n0Y1bNcWcsmO2c8DC2q760umvP5AuAvb7uz3Lek5FDR0uk9Ug3/Dz7sxyNBcCo4tl\nlIAFvHt4a0qXRDum5FzFxythgUPZ\n-----END CERTIFICATE-----"}, :overwrite=>true}
      savon.expects(:certificate_import_from_pem).with(message: message).returns(fixture)
      provider.content=('boop')
    end
  end


end
