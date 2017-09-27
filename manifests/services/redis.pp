# Install and configure standalone redis-server for sensu

class profile::services::redis {

  require ::firewall

  $nodetype = hiera('profile::redis::nodetype')
  $nic = hiera('profile::interfaces::management')
  $ip = $::networking['interfaces'][$nic]['ip']
  $redispass = hiera('profile::redis::masterauth')
  $redismaster = hiera('profile::redis::master')

  if ( $nodetype == 'slave' ) {
    $slaveof = "${redismaster} 6379"
    $masterauth = $redispass
    $requirepass = undef
  }
  elsif ( $nodetype == 'master') {
    $slaveof = undef
    $masterauth = undef
    $requirepass = $redispass
  }
  else {
    fail('Wrong redis node type. Only master or slave are valid')
  }

  class { '::redis':
    config_owner        => 'redis',
    config_group        => 'redis',
    manage_repo         => true,
    bind                => "127.0.0.1 ${ip}",
    masterauth          => $masterauth,
    min_slaves_to_write => 1,
    requirepass         => $requirepass,
    slaveof             => $slaveof,
  } ->

  class { '::redis::sentinel':
    redis_host => $redismaster,
    auth_pass  => $masterauth,
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
