#!/usr/bin/env rspec

require 'spec_helper'

res_type_name = :f5_certificate
res_type = Puppet::Type.type(res_type_name)

describe res_type do
  let(:provider) {
    prov = stub 'provider'
    prov.stubs(:name).returns(res_type_name)
    prov
  }
  let(:res_type) {
    val = res_type
    val.stubs(:defaultprovider).returns provider
    val
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
  it_should_behave_like "a puppet type", parameter_tests, :f5_certificate

  it "parameter content certificate should be munged into a fingerprint" do
    resource[:content] = <<EOS
-----BEGIN CERTIFICATE-----
MIICWjCCAcMCAgGlMA0GCSqGSIb3DQEBBAUAMHUxCzAJBgNVBAYTAlVTMRgwFgYD
VQQKEw9HVEUgQ29ycG9yYXRpb24xJzAlBgNVBAsTHkdURSBDeWJlclRydXN0IFNv
bHV0aW9ucywgSW5jLjEjMCEGA1UEAxMaR1RFIEN5YmVyVHJ1c3QgR2xvYmFsIFJv
b3QwHhcNOTgwODEzMDAyOTAwWhcNMTgwODEzMjM1OTAwWjB1MQswCQYDVQQGEwJV
UzEYMBYGA1UEChMPR1RFIENvcnBvcmF0aW9uMScwJQYDVQQLEx5HVEUgQ3liZXJU
cnVzdCBTb2x1dGlvbnMsIEluYy4xIzAhBgNVBAMTGkdURSBDeWJlclRydXN0IEds
b2JhbCBSb290MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCVD6C28FCc6HrH
iM3dFw4usJTQGz0O9pTAipTHBsiQl8i4ZBp6fmw8U+E3KHNgf7KXUwefU/ltWJTS
r41tiGeA5u2ylc9yMcqlHHK6XALnZELn+aks1joNrI1CqiQBOeacPwGFVw1Yh0X4
04Wqk2kmhXBIgD8SFcd5tB8FLztimQIDAQABMA0GCSqGSIb3DQEBBAUAA4GBAG3r
GwnpXtlR22ciYaQqPEh346B8pt5zohQDhT37qw4wxYMWM4ETCJ57NE7fQMh017l9
3PR2VX2bY1QY6fDq81yx2YtCHrnAlU66+tXifPVoYb+O7AWXX1uw16OFNMQkpw0P
lZPvy5TYnh+dXIVtx6quTx8itc2VrbqnzPmrC3p/
-----END CERTIFICATE-----
EOS
    resource[:content].should == "sha1([\"97817950d81c9670cc34d809cf794431367ef474\"])"
  end

  it "parameter content multiple certificate should be munged into fingerprints" do
    resource[:content] = <<EOS
-----BEGIN CERTIFICATE-----
MIICWjCCAcMCAgGlMA0GCSqGSIb3DQEBBAUAMHUxCzAJBgNVBAYTAlVTMRgwFgYD
VQQKEw9HVEUgQ29ycG9yYXRpb24xJzAlBgNVBAsTHkdURSBDeWJlclRydXN0IFNv
bHV0aW9ucywgSW5jLjEjMCEGA1UEAxMaR1RFIEN5YmVyVHJ1c3QgR2xvYmFsIFJv
b3QwHhcNOTgwODEzMDAyOTAwWhcNMTgwODEzMjM1OTAwWjB1MQswCQYDVQQGEwJV
UzEYMBYGA1UEChMPR1RFIENvcnBvcmF0aW9uMScwJQYDVQQLEx5HVEUgQ3liZXJU
cnVzdCBTb2x1dGlvbnMsIEluYy4xIzAhBgNVBAMTGkdURSBDeWJlclRydXN0IEds
b2JhbCBSb290MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCVD6C28FCc6HrH
iM3dFw4usJTQGz0O9pTAipTHBsiQl8i4ZBp6fmw8U+E3KHNgf7KXUwefU/ltWJTS
r41tiGeA5u2ylc9yMcqlHHK6XALnZELn+aks1joNrI1CqiQBOeacPwGFVw1Yh0X4
04Wqk2kmhXBIgD8SFcd5tB8FLztimQIDAQABMA0GCSqGSIb3DQEBBAUAA4GBAG3r
GwnpXtlR22ciYaQqPEh346B8pt5zohQDhT37qw4wxYMWM4ETCJ57NE7fQMh017l9
3PR2VX2bY1QY6fDq81yx2YtCHrnAlU66+tXifPVoYb+O7AWXX1uw16OFNMQkpw0P
lZPvy5TYnh+dXIVtx6quTx8itc2VrbqnzPmrC3p/
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIDITCCAoqgAwIBAgIBADANBgkqhkiG9w0BAQQFADCByzELMAkGA1UEBhMCWkEx
FTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTESMBAGA1UEBxMJQ2FwZSBUb3duMRowGAYD
VQQKExFUaGF3dGUgQ29uc3VsdGluZzEoMCYGA1UECxMfQ2VydGlmaWNhdGlvbiBT
ZXJ2aWNlcyBEaXZpc2lvbjEhMB8GA1UEAxMYVGhhd3RlIFBlcnNvbmFsIEJhc2lj
IENBMSgwJgYJKoZIhvcNAQkBFhlwZXJzb25hbC1iYXNpY0B0aGF3dGUuY29tMB4X
DTk2MDEwMTAwMDAwMFoXDTIwMTIzMTIzNTk1OVowgcsxCzAJBgNVBAYTAlpBMRUw
EwYDVQQIEwxXZXN0ZXJuIENhcGUxEjAQBgNVBAcTCUNhcGUgVG93bjEaMBgGA1UE
ChMRVGhhd3RlIENvbnN1bHRpbmcxKDAmBgNVBAsTH0NlcnRpZmljYXRpb24gU2Vy
dmljZXMgRGl2aXNpb24xITAfBgNVBAMTGFRoYXd0ZSBQZXJzb25hbCBCYXNpYyBD
QTEoMCYGCSqGSIb3DQEJARYZcGVyc29uYWwtYmFzaWNAdGhhd3RlLmNvbTCBnzAN
BgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAvLyTU23AUE+CFeZIlDWmWr5vQvoPR+53
dXLdjUmbllegeNTKP1GzaQuRdhciB5dqxFGTS+CN7zeVoQxN2jSQHReJl+A1OFdK
wPQIcOk8RHtQfmGakOMj04gRRif1CwcOu93RfyAKiLlWCy4cgNrx454p7xS9CkT7
G1sY0b8jkyECAwEAAaMTMBEwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQQF
AAOBgQAt4plrsD16iddZopQBHyvdEktTwq1/qqcAXJFAVyVKOKqEcLnZgA+le1z7
c8a914phXAPjLSeoF+CEhULcXpvGt7Jtu3Sv5D/Lp7ew4F2+eIMllNLbgQ95B21P
9DkVWlIBe94y1k049hJcBlDfBVu9FEuh3ym6O0GN92NWod8isQ==
-----END CERTIFICATE-----
EOS
    resource[:content].should == "sha1([\"40e78c1d523d1cd9954fac1a1ab3bd3cbaa15bfc\", \"97817950d81c9670cc34d809cf794431367ef474\"])"
  end
end
