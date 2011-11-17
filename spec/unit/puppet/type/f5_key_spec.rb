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

  it "parameter content should munge key into a fingerprint" do
    resource[:content] = <<EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAuMKnp+QyUIEii4LnYeetlgbKXfmMrhHx8ZvpdwHlh9FCo2T8
VqwUlpJQPTX4WMbFd/jADDfHJIK6Zti4VWf11SwVMO7GCTTPqDIC5ujDZmBY9ViI
eOCBtbKnFP7AL2GRRWNhZgkNv4VQo71PVgwkdPxdHePR8jUQABkYFAucneALLKg3
2lFTqV4QTITr1bc2KQ4gMGABLLBq91mYvMbva9VQmyrNsuYzhwaA5GnEG9NTRTwP
5MPdBc6jB3r2g4nQBchEWnNa286MNFvgh6qOLHG1/rvf0KW97aG9fgkchnx/XW/M
GojwzpGG6pr3bs04hS4Pnh0afKpFGevhyc07OQIDAQABAoIBAB2Ar8bmcIZcaIjA
iXQfy582TGA/NhChuvGqxNgFDILojmyK9qRcbBkzGe78TEDY1LV4mioZSgpxeZRs
rNqudBnrJSMgLa1QqowgGEiJCJKzdeEPlxM+PlgmQ/ndSBEI0mqzGN1zOqfHgP30
f9OssrGfjrr0IxU7Fef+GdMxm3u2Ai+jty03IxUS2tZbhmjK4PdVY+CcBv5Mbrww
p0vbshQ2Qd/xfvdDIU5vNeqIOX+qmHXKypaUv1Bv72htirB5sQiOs00Nd0F4xvxA
3WbBoqjM17U/iRsoh8RapF/sfUmXdEXu2Ygbmut9fF+drNfj8zw51KbrI0kxLr+f
pqd62lECgYEA7t294rrE5K3Jb9E+PIJ/hsi/mIanAYJhnQQGo0EQw+Ei9fyOFY/e
mhJTCZe1Y/jsYTFSorX+8UzcUsGkIkVoYVTWz0hP9yE+Si4tJUEvdJj+IyCpkQ3z
7/SMuY4zGdIiKsUct7SBsgn3Pa/JyTThFLvOQps5sNhpq9nqa1MuXP0CgYEAxgNg
qX7+WRutSYlh0cjyzfk80F2Sv8Lh2QRKoTjOj4v15I8FP+8eMFnm5u2j0EyuiDHS
w9HaOu1v298SzujSEEjJ1N88zG4FAZbVO1I/FU8RBr58BqDMZarwWkzSPPjg7Sh6
n8lwxpTXiyEU1ST80fSMhXCuX3tKaNfut7nhSe0CgYBG4DjVq8F8cSySJy4mWjpo
zew738hyJDO+mVE247mLxaPQBY5LS5MreEB3WjKSZWwOMspoSURKaRn+3EJNgPbF
2pyaiMRhedW3wRfYNA1WtYbC+ZAW4GL/UjrnXBBBmx5UPoSU5dSN9XMNNLnVIAGh
W1CKZvCpTq2cNl7eVaIuKQKBgEMSa9CeApu+Y0EwduDvl0crsGzH9WhdI9E1we3A
Zz96Yi0sQNP6NBieqzb3sfBhuRDLB6Bq2efx+1zXv/A0LstzTGJ9x4NblPiH1eyF
HHckVBkbtrksCHA7qbR8pw4eI1pRxs+PFVM+oZAwAXV9VOHtWxfsJjSTd43x7ptv
LB+1AoGBAMUcE2wVE9RWmOeb+B7Mzlj4Ekp2nRe/e3jNfKYoe93PYnoyBDXi6H6F
Y/Fsl94paNUtEXOQgM/wS9pevspx7XqMxZitOjjQTdv018t6K+6wvfVpYJS5hUzy
NThVuSfa8qmUsFcDlMxkH+ubM+TKCmtfoyx4oukzK/4Qdv+o4OAc
-----END RSA PRIVATE KEY-----
EOS
   resource[:content].should == "sha1([\"ae0a952c2fb3a5a8b473d31ca5bea7371a8447af\"])"
  end

  it "parameter content should only munge keys into a fingerprint" do
    resource[:content] = <<EOS
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAuMKnp+QyUIEii4LnYeetlgbKXfmMrhHx8ZvpdwHlh9FCo2T8
VqwUlpJQPTX4WMbFd/jADDfHJIK6Zti4VWf11SwVMO7GCTTPqDIC5ujDZmBY9ViI
eOCBtbKnFP7AL2GRRWNhZgkNv4VQo71PVgwkdPxdHePR8jUQABkYFAucneALLKg3
2lFTqV4QTITr1bc2KQ4gMGABLLBq91mYvMbva9VQmyrNsuYzhwaA5GnEG9NTRTwP
5MPdBc6jB3r2g4nQBchEWnNa286MNFvgh6qOLHG1/rvf0KW97aG9fgkchnx/XW/M
GojwzpGG6pr3bs04hS4Pnh0afKpFGevhyc07OQIDAQABAoIBAB2Ar8bmcIZcaIjA
iXQfy582TGA/NhChuvGqxNgFDILojmyK9qRcbBkzGe78TEDY1LV4mioZSgpxeZRs
rNqudBnrJSMgLa1QqowgGEiJCJKzdeEPlxM+PlgmQ/ndSBEI0mqzGN1zOqfHgP30
f9OssrGfjrr0IxU7Fef+GdMxm3u2Ai+jty03IxUS2tZbhmjK4PdVY+CcBv5Mbrww
p0vbshQ2Qd/xfvdDIU5vNeqIOX+qmHXKypaUv1Bv72htirB5sQiOs00Nd0F4xvxA
3WbBoqjM17U/iRsoh8RapF/sfUmXdEXu2Ygbmut9fF+drNfj8zw51KbrI0kxLr+f
pqd62lECgYEA7t294rrE5K3Jb9E+PIJ/hsi/mIanAYJhnQQGo0EQw+Ei9fyOFY/e
mhJTCZe1Y/jsYTFSorX+8UzcUsGkIkVoYVTWz0hP9yE+Si4tJUEvdJj+IyCpkQ3z
7/SMuY4zGdIiKsUct7SBsgn3Pa/JyTThFLvOQps5sNhpq9nqa1MuXP0CgYEAxgNg
qX7+WRutSYlh0cjyzfk80F2Sv8Lh2QRKoTjOj4v15I8FP+8eMFnm5u2j0EyuiDHS
w9HaOu1v298SzujSEEjJ1N88zG4FAZbVO1I/FU8RBr58BqDMZarwWkzSPPjg7Sh6
n8lwxpTXiyEU1ST80fSMhXCuX3tKaNfut7nhSe0CgYBG4DjVq8F8cSySJy4mWjpo
zew738hyJDO+mVE247mLxaPQBY5LS5MreEB3WjKSZWwOMspoSURKaRn+3EJNgPbF
2pyaiMRhedW3wRfYNA1WtYbC+ZAW4GL/UjrnXBBBmx5UPoSU5dSN9XMNNLnVIAGh
W1CKZvCpTq2cNl7eVaIuKQKBgEMSa9CeApu+Y0EwduDvl0crsGzH9WhdI9E1we3A
Zz96Yi0sQNP6NBieqzb3sfBhuRDLB6Bq2efx+1zXv/A0LstzTGJ9x4NblPiH1eyF
HHckVBkbtrksCHA7qbR8pw4eI1pRxs+PFVM+oZAwAXV9VOHtWxfsJjSTd43x7ptv
LB+1AoGBAMUcE2wVE9RWmOeb+B7Mzlj4Ekp2nRe/e3jNfKYoe93PYnoyBDXi6H6F
Y/Fsl94paNUtEXOQgM/wS9pevspx7XqMxZitOjjQTdv018t6K+6wvfVpYJS5hUzy
NThVuSfa8qmUsFcDlMxkH+ubM+TKCmtfoyx4oukzK/4Qdv+o4OAc
-----END RSA PRIVATE KEY-----
------BEGIN X509 CRL-----
-MIIBmjCCAQMwDQYJKoZIhvcNAQEEBQAwgb0xCzAJBgNVBAYTAlVTMRMwEQYDVQQI
-EwpDYWxpZm9ybmlhMRAwDgYDVQQHEwdPYWtsYW5kMRYwFAYDVQQKEw1SZWQgSGF0
-LCBJbmMuMSIwIAYDVQQLFBlHbG9iYWwgU2VydmljZXMgJiBTdXBwb3J0MR0wGwYD
-VQQDExRSZWQgSGF0IFRlc3QgUm9vdCBDQTEsMCoGCSqGSIb3DQEJARYdc3Ryb25n
-aG9sZC1zdXBwb3J0QHJlZGhhdC5jb20XDTAwMTExMzIwNTcyNVoXDTAwMTIxMzIw
-NTcyNVowFDASAgEBFw0wMDA4MzEyMTE5MTdaMA0GCSqGSIb3DQEBBAUAA4GBAIge
-X5VaOkNOKn8MrbxFiqpOrH/M9Vocu9oDeQ6EMTeA5xIWBGN53BZ/HUJ1NjS32VDG
-waM3P6DXud4xKXauVgAXyH6D6xEDBt5GIBTFrWKIDKGOkvRChTUvzObmx9ZVSMMg
-5xvAbsaFgJx3RBbznySlqVU4APYE0W2/xL0/8fzM
------END X509 CRL-----
EOS
   resource[:content].should == "sha1([\"ae0a952c2fb3a5a8b473d31ca5bea7371a8447af\"])"
  end
end
