# Install and configure sensu-client
class profile::sensu::client {
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $rabbithosts = hiera('profile::rabbitmq::servers')
  $mgmt_nic = hiera('profile::interfaces::management')
  $client_ip = getvar("::ipaddress_${mgmt_nic}")
  $subs_from_client_conf = hiera('sensu::subscriptions','')
  $redishost = hiera('profile::redis::ip')

  if ( $::is_virtual ) {
    $subs = [ 'all' ]
  } else {
    $subs = [ 'all', 'physical-servers' ]
  }

  if ( $subs_from_client_conf != '' )  {
    $subscriptions = concat($subs, $subs_from_client_conf)
  } else {
    $subscriptions = $subs
  }

  $rabbit_cluster = $rabbithosts.map |$host| {
    {
      port      => 5672,
      host      => $host,
      user      => 'sensu',
      password  => $sensurabbitpass,
      vhost     => '/sensu',
      heartbeat => 2,
      prefetch  => 1,
    }
  }

  class { '::sensu':
    rabbitmq_cluster             => $rabbit_cluster,
    transport_reconnect_on_error => true,
    redis_host                   => $redishost,
    redis_reconnect_on_error     => true,
    server                       => false,
    api                          => false,
    client                       => true,
    client_address               => $client_ip,
    sensu_plugin_provider        => 'sensu_gem',
    use_embedded_ruby            => true,
    subscriptions                => $subscriptions,
    purge                        => true,
  }

  include ::profile::sensu::plugins
}
