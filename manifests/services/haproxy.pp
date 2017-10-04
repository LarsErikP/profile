# Baseconfig for all haproxy servers

class profile::services::haproxy {

  class { '::haproxy':
    merge_options    => true,
    defaults_options => {
      'option'  => [
        'httplog',
        'dontlognull',
        'log-health-checks',
        'redispatch',
        'forwardfor',
        'http-server-close',
      ],
      'timeout' => [
        'connect 3s',
        'server 6s',
        'client 6s',
      ],
    },
  }
}
