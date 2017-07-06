# FAIERVÅLL

class profile::baseconfig::firewall_post {
  require ::firewall

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }
}
