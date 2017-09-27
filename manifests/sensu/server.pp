# Install and configure sensu-server and dashboard
class profile::sensu::server {
  require ::profile::services::redis

  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $subs_from_client_conf = hiera('sensu::subscriptions','')

  $redishost = hiera('profile::redis::ip')

  if ( $::is_virtual == 'true' ) {
    $subs = [ 'all' ]
  } else {
    $subs = [ 'all', 'physical-servers' ]
  }

  if ( $subs_from_client_conf != '' )  {
    $subscriptions = concat($subs, $subs_from_client_conf)
  } else {
    $subscriptions = $subs
  }

  class { '::sensu':
    rabbitmq_host               => $rabbithost,
    rabbitmq_password           => $sensurabbitpass,
    rabbitmq_reconnect_on_error => true,
    redis_host                  => $redishost,
    server                      => true,
    api                         => true,
    use_embedded_ruby           => true,
    sensu_plugin_provider       => 'sensu_gem',
    subscriptions               => $subscriptions,
    purge                       => true,
  }

  sensu::handler { 'default':
    type     => 'set',
    handlers => [ 'stdout' ],
  }

  sensu::handler { 'stdout':
    type    => 'pipe',
    command => 'cat',
  }

  sensu::filter { 'state-change-only':
    negate     => false,
    attributes => {
      occurrences => "eval: value == 1 || ':::action:::' == 'resolve'",
    },
  }

#  include ::profile::sensu::checks
#  include ::profile::sensu::plugins
#  include ::profile::sensu::plugin::http
  include ::profile::sensu::uchiwa
}
