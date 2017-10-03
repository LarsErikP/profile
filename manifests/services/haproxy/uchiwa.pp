# Haproxy config for uchiwa

class profile::services::haproxy::uchiwa {

  haproxy::frontend { 'ft_uchiwa':
    ipaddress => '*',
    ports     => '80,443',
    mode      => 'http',
    options   => {
      'default_backend' => 'bk_uchiwa',
    },
  }

  haproxy::backend { 'bk_uchiwa':
    mode    => 'http', 
    options => {
      'balance' => 'source',
      'cookie'  => 'SERVERID insert indirect nocache',
    },
  }
}
