# Install and configure standalone redis-server for sensu

class profile::services::redis {

  require ::firewall

  $nodetype = hiera('profile::redis::nodetype')
  $nic = hiera('profile::interfaces::management')
  # The line below is not compatible with puppet 3:
  $ip = $::facts['networking']['interfaces'][$nic]['ip']
  $redismaster = hiera('profile::redis::master')
  $masterauth = hiera('profile::redis::masterauth')
  $enable_haproxy = hiera('profile::redis::haproxy::enable', false)

  if ( $nodetype == 'slave' ) {
    $slaveof = "${redismaster} 6379"
  }
  elsif ( $nodetype == 'master') {
    $slaveof = undef
  }
  else {
    fail('Wrong redis node type. Only master or slave are valid')
  }

  $extra_opts = {}
  if ( $slaveof != undef ) {
    $extra_opts = { 'min_slaves_to_write' => 1, }
  }

  class { '::redis':
    config_owner => 'redis',
    config_group => 'redis',
    manage_repo  => true,
    bind         => "${ip} 127.0.0.1",
    slaveof      => $slaveof,
    masterauth   => $masterauth,
    requirepass  => $masterauth,
    *            => $extra_opts,
  } ->

  class { '::redis::sentinel':
    down_after       => 5000,
    failover_timeout => 60000,
    redis_host       => $redismaster,
    log_file         => '/var/log/redis/redis-sentinel.log',
    sentinel_bind    => "${ip} 127.0.0.1",
  }

  if ($enable_haproxy) {
    @@haproxy::balancermember { $::fqdn:
      defaults          => 'redis',
      listening_service => 'bk_redis',
      ports             => '6379',
      ipaddresses       => $ip,
      server_names      => $::hostname,
      options           => [
        'backup check inter 1s',
      ],
    }
  }

  firewall { '050 accept redis-server':
    proto  => 'tcp',
    dport  => 6379,
    action => 'accept',
  }
  firewall { '051 accept redis-sentinel':
    proto  => 'tcp',
    dport  => 26379,
    action => 'accept',
  }
}
