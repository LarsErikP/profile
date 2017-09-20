# Install and configure sensu-server and dashboard
class profile::sensu::server {
  require ::profile::services::redis
  require ::profile::services::keepalived

  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $subs_from_client_conf = hiera('sensu::subscriptions','')

  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::sensu::vrrp::id')
  $vrpri = hiera('profile::sensu::vrrp::priority')

  $management_if = hiera('profile::interfaces::management')

  $sensu_ip = hiera('profile::sensu::vrrp::admin::ip')

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
    server                      => true,
    api                         => true,
    use_embedded_ruby           => true,
    api_bind                    => '127.0.0.1',
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

  keepalived::vrrp::script { 'check_sensu':
    script => '/usr/bin/killall -0 sensu-server',
  }

  keepalived::vrrp::instance { 'mgmt-sensu':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${sensu_ip}/32",
    ],
    track_script      => 'check_sensu',
  }
#  include ::profile::sensu::checks
#  include ::profile::sensu::plugins
#  include ::profile::sensu::plugin::http
  include ::profile::sensu::uchiwa
}
