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
  firewall { '004 range test':
    proto  => 'udp',
    dport  => '5000-6000',
    action => 'accept',
  } ->
  firewall { '005 port list test':
    proto  => 'tcp',
    dport  => [ '1234', '3000', '4500-4503', '8080'],
    action => 'accept',
  }
}
