Puppet::Type.newtype(:f5_inet) do
  @doc = "Manage F5 inet properties."

  apply_to_device

  newparam(:name, :namevar=>true) do
    desc "The BigIP host name."
    newvalues(/^[[:alpha:][:digit:]\.\-]+$/)
    munge do |value|
      resource[:hostname]=value
    end
  end

  newproperty(:hostname) do
    desc "The BigIP host name."
    newvalues(/^[[:alpha:][:digit:]\.\-]+$/)
  end

  newproperty(:ntp_server_address) do
    desc "The NTP server address."
    newvalues(/^[[:alpha:][:digit:]\.\-]+$|^$/)
  end
end
