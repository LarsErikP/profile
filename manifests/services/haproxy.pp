# Install and configure haproxy

class profile::services::haproxy {
  class { '::haproxy':
    default_options => {
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

  $installSensu = hiera('profile::sensu::install')
  if ( $installSensu ) {
    include ::profile::services::haproxy::uchiwa
  }

}
