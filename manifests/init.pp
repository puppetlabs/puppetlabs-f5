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
class f5 {
  package {'f5-icontrol':
    ensure   => present,
    provider => 'gem',
  }
}
