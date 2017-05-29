# This class installs varios basic tools.


class profile::baseconfig::packages {

  $basepackages = hiera_array('profile::baseconfig::packages')

  # Install a range of useful tools.
  package { $basepackages :
    ensure => 'present',
  }

}
