# Install and configure standalone redis-server for sensu

class profile::services::redis {
  $nodetype = hiera('profile::redis::nodetype')
  $nic = hiera('profile::interfaces::management')
  $ip = $::networking['interfaces'][$nic]['ip']
  $masterauth = hiera('profile::redis::masterauth')
  $redismaster = hiera('profile::redis::master')
  $slaveof = undef

  if ( $nodetype == 'slave' ) {
    $slaveof = "${redismaster} 6379"
  }
  elsif ( $nodetype == 'master') {
    $slaveof = undef
  }
  else {
    fail('Wrong redis node type. Only master or slave are valid')
  }

  class { '::redis':
    config_owner => 'redis',
    config_group => 'redis',
    manage_repo  => true,
    bind         => $ip,
    masterauth   => $masterauth,
    slaveof      => $slaveof,
  } ->

  class { '::redis::sentinel':
    redis_host => $redismaster,
    auth_pass  => $masterauth,
  }
}
