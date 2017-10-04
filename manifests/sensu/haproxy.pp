# Haproxy config for uchiwa

class profile::sensu::haproxy {

  require ::profile::services::haproxy

  haproxy::listen { 'uchiwa':
    ipaddress   => '*',
    ports       => '80,443',
    mode        => 'http',
    options     => {
      'balance' => 'source',
      'cookie'  => 'SERVERID insert indirect nocache',
    },
  }
}
