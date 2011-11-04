#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_key
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
    res_type.new({:name => 'test'})
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
    :real_content => {
      :default => nil,
    },
    :content => {
      :default => nil,
    },
    :mode => {
      :valid => [
        "MANAGEMENT_MODE_DEFAULT",
        "MANAGEMENT_MODE_WEBSERVER",
        "MANAGEMENT_MODE_EM",
        "MANAGEMENT_MODE_IQUERY",
        "MANAGEMENT_MODE_IQUERY_BIG3D",
      ],
      :invalid => [
        "anything else",
      ],
      :default => "MANAGEMENT_MODE_DEFAULT",
    }
  }

  it_should_behave_like "a puppet type", parameter_tests, :f5_key

  it "parameter content X509 data should be munged into a fingerprint" do
    resource[:content] = <<EOS
-----BEGIN X509 CRL-----
MIIBmjCCAQMwDQYJKoZIhvcNAQEEBQAwgb0xCzAJBgNVBAYTAlVTMRMwEQYDVQQI
EwpDYWxpZm9ybmlhMRAwDgYDVQQHEwdPYWtsYW5kMRYwFAYDVQQKEw1SZWQgSGF0
LCBJbmMuMSIwIAYDVQQLFBlHbG9iYWwgU2VydmljZXMgJiBTdXBwb3J0MR0wGwYD
VQQDExRSZWQgSGF0IFRlc3QgUm9vdCBDQTEsMCoGCSqGSIb3DQEJARYdc3Ryb25n
aG9sZC1zdXBwb3J0QHJlZGhhdC5jb20XDTAwMTExMzIwNTcyNVoXDTAwMTIxMzIw
NTcyNVowFDASAgEBFw0wMDA4MzEyMTE5MTdaMA0GCSqGSIb3DQEBBAUAA4GBAIge
X5VaOkNOKn8MrbxFiqpOrH/M9Vocu9oDeQ6EMTeA5xIWBGN53BZ/HUJ1NjS32VDG
waM3P6DXud4xKXauVgAXyH6D6xEDBt5GIBTFrWKIDKGOkvRChTUvzObmx9ZVSMMg
5xvAbsaFgJx3RBbznySlqVU4APYE0W2/xL0/8fzM
-----END X509 CRL-----
EOS
    resource[:content].should == "sha1(17b8aaaa9fc731da07ea4cb627490a7b159ee7e1)"
  end

end
