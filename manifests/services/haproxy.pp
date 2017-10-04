# Baseconfig for all haproxy servers

class profile::services::haproxy {

  class { '::haproxy':
    merge_options    => true,
    global_options   => {
      'log' => [
        '/dev/log local0',
        '/dev/log local1 notice',
      ],
    },
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
        'connect 5s',
        'server 50s',
        'client 50s',
      ],
    },
  }
}
