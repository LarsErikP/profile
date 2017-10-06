# Haproxy config for uchiwa

class profile::sensu::haproxy {

  require ::profile::services::haproxy

  haproxy::defaults { 'uchiwa':
    options =>  {
      'log'     => 'global',
      'mode'    => 'http',
      'timeout' => [
        'connect 5s',
        'server 50s',
        'client 50s',
        'http-request 10s',
      ],
      'option'  => [
        'forwardfor',
        'http-server-close',
        'httplog',
        'log-health-checks',
        'redispatch',
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

  firewall { '040 accept http':
    proto  => 'tcp',
    dport  => 80,
    action => 'accept',
  }
  firewall { '041 accept https':
    proto  => 'tcp',
    dport  => 443,
    action => 'accept',
  }
}
