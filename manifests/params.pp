class f5::params {
  if $::puppetversion =~ /Puppet Enterprise/ {
    $owner    = 'pe-puppet'
    $group    = 'pe-puppet'
    $provider = 'pe_gem'
  } else {
    $owner    = 'puppet'
    $group    = 'puppet'
    $provider = 'gem'
  }

  $mode = '0644'
}
