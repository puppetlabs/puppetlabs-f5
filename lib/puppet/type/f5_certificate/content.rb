module Puppet
  Puppet::Type.type(:f5_certificate).newproperty(:content) do
    attr_reader :real_content
    desc "The certificate file content."

    # Rather inefficient to download, compare, then upload certificate.
    # instead convert file to F5 iControl KeyCertificate CertificateDetail
    munge do |value|
      if value == :absent
        value
      else
        @real_content = value

        # http://devcentral.f5.com/wiki/iControl.Management__KeyCertificate__CertificateDetail.ashx
        # cert_info          Certificate     The basic information of the certificate.
        # cert_type          CertificateType The certificate type.
        # key_type           KeyType         The key type of the key used when the certificate is created.
        # bit_length         long            The bit length of the key used when the certificate is created.
        # version            long            The version of the certificate.
        # serial_number      String          The serial number of the certificate (if assigned).
        # expiration_string  String          The string representation of the expiration date.
        # expiration_date    long            The numeric representation of the expiration date.
        # subject            X509Data        The x509 data of the certificate's owner.
        # issuer             X509Data        The x509 data of the authority who signs this certificate.
        #cert_info
        value
      end
    end
  end
end
