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

  if !defined(File["${settings::confdir}/device"]) {
    file { "${settings::confdir}/device":
      ensure => directory,
      owner  => $owner,
      group  => $group,
      mode   => $mode,
    }
  }
}
