# Defined Resource Type: f5::config
#
#   This defined resource type will create an f5 device configuration file
#     to be used with Puppet.
#
# Parameters:
#
# [*username*] - The username used to connect to the f5 device
# [*password*] - The password used to connect to the f5 device
# [*url*]      - The url to the f5 device. DO NOT INCLUDE https://
# [*target*]   - The path to the f5 configuration file we are creating
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
#  f5::config { 'bigip':
#    username  => 'admin',
#    password  => 'password',
#    url       => 'f5.puppetlabs.lan',
#    partition => 'Common',
#    target    => '/etc/puppetlabs/puppet/device/bigip.conf
#  }
#
define f5::config(
  $username = 'admin',
  $password,
  $url,
  $partition = 'Common',
  $target
) {

  file { $target:
    ensure => present,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0644',
    content => template('f5/config.erb'),
  }

}
