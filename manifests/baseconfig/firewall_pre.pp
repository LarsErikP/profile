# FAIERVÅLL

class profile::baseconfig::firewall_pre {
  require ::firewall

  firewall { '000 accept all icmp':
    proto  => 'icmp',
    action => 'accept',
  } ->
  firewall { '001 accept all to loopback':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  } ->
  firewall { '002 accept related established':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  } ->
  firewall { '003 accept ssh':
    proto  => 'tcp',
    dport  => 22,
    action => 'accept',
  } ->
  firewall { '004 accept telnet - lol':
    proto  => 'tcp',
    dport  => 23,
    action => 'accept',
  }
}
