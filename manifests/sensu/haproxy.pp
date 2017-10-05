# Haproxy config for uchiwa

class profile::sensu::haproxy {

  require ::profile::services::haproxy

  haproxy::defaults { 'uchiwa':
    options =>  {
      'log'     => 'global',
      'mode'    => 'http',
      'timeout' => [
        'connect 5s'.
        'server 50s',
        'client 50s',
      ],
      'option'  => [
        'forwardfor',
        'http-server-close',
      ],
    },
  }

  haproxy::frontend { 'ft_uchiwa':
    ipaddress => '*',
    ports     => '80,443',
    defaults  => 'uchiwa',
    options   => {
      'default_backend' => 'bk_uchiwa',
    },
  }

  haproxy::backend { 'bk_uchiwa':
    defaults => 'uchiwa',
    options  => {
      'balance' => 'source',
      'cookie'  => 'SERVERID insert indirect nocache',
    },
  }
}
