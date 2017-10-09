# Baseconfig for all haproxy servers

class profile::services::haproxy {

  require ::firewall

  class { '::haproxy':
    merge_options  => true,
    global_options => {
      'log'     => [
        '/dev/log local0',
        '/dev/log local1 notice',
      ],
      'maxconn' => '8000',
    },
  }

  haproxy::listen { 'stats':
    ipaddress => '*',
    ports     => '9000',
    options   => {
      'mode'  => 'http',
      'stats' => [
        'hide-version',
        'refresh 30s',
        'show-node',
        'uri /',
      ],
    },
  }

  firewall { '060 accept haproxy stats':
    proto  => 'tcp',
    dport  => 9000,
    action => 'accept',
  }
}
