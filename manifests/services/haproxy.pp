# Baseconfig for all haproxy servers

class profile::services::haproxy {

  require ::firewall

  $installSensu = hiera('profile::sensu::install')

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

  firewall { '060 accept haproxy stats':
    proto  => 'tcp',
    dport  => 9000,
    action => 'accept',
  }

  if ( $installSensu ) {
    @@sensu::check { 'haproxy-stats':
      command     => 'check-haproxy.rb -S localhost -q / -P 9000 -A',
      interval    => 300,
      standalone  => false,
      subscribers => [ 'haproxy-servers' ],
      tag         => 'sensu-check',
    }
  }
}
