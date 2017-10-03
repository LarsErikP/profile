# Install and configure haproxy

class profile::services::haproxy {

  $listeners = hiera_array('profile::services::haproxy::listeners', undef)

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

  if ( $listeners ) {
    $listeners.each |$listener|  {
      include "::profile::services::haproxy::${listener}"
    }
  }
}
