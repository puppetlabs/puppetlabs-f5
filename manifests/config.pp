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
  $username  = 'admin',
  $password  = 'admin',
  $url       = $name,
  $partition = 'Common',
  $target    = "${settings::confdir}/device/${name}.conf"
) {

  include f5::params

  $owner = $f5::params::owner
  $group = $f5::params::group
  $mode  = $f5::params::mode

  file { $target:
    ensure  => present,
    owner   => $owner,
    group   => $group,
    mode    => $mode,
    content => template('f5/config.erb'),
  }
}
