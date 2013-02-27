# Class: f5
#
#   Deploy necessary component to manage F5 devices on proxy systems.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class f5 (
  $owner    = $f5::params::owner,
  $group    = $f5::params::group,
  $provider = $f5::params::provider,
  $mode     = $f5::params::mode
) inherits f5::params {

  file { '/opt/f5':
    ensure => directory,
  }

  file { '/opt/f5/f5-icontrol.gem':
    source => 'puppet:///modules/f5/f5-icontrol-10.2.0.2.gem',
  }

  if !defined(File["${settings::confdir}/device"]) {
    file { "${settings::confdir}/device":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }
  }

  package {'f5-icontrol':
    ensure   => present,
    source   => '/opt/f5/f5-icontrol.gem',
    provider => $provider,
    require  => File['/opt/f5/f5-icontrol.gem'],
  }
}
