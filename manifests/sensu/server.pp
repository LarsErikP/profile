# Install and configure sensu-server and dashboard
class profile::sensu::server {

  $rabbithost = hiera('profile::rabbitmq::ip')
  $sensurabbitpass = hiera('profile::sensu::rabbit_password')
  $subs_from_client_conf = hiera('sensu::subscriptions','')

  $redishost = hiera('profile::redis::ip')
  $redismasterauth = hiera('profile::redis::masterauth')

  $sensu_url = hiera('profile::sensu::mailer::url',undef)
  $mail_from = hiera('profile::sensu::mailer::mail_from',undef)
  $mail_to = hiera('profile::sensu::mailer::mail_to',undef)
  $smtp_address = hiera('profile::sensu::mailer::smtp_address',undef)
  $smtp_port = hiera('profile::sensu::mailer::smtp_port',undef)
  $smtp_domain = hiera('profile::sensu::mailer::smtp_domain',undef)

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

  class { '::sensu':
    rabbitmq_host                => $rabbithost,
    rabbitmq_password            => $sensurabbitpass,
    transport_reconnect_on_error => true,
    redis_host                   => $redishost,
    redis_password               => $redismasterauth,
    redis_reconnect_on_error     => true,
    server                       => true,
    api                          => true,
    use_embedded_ruby            => true,
    sensu_plugin_provider        => 'sensu_gem',
    subscriptions                => $subscriptions,
    purge                        => true,
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

  if ($mail_from) {
    sensu::handler { 'mailer':
    type    => 'pipe',
    command => 'handler-mailer.rb',
    config  => {
      admin_gui    => $sensu_url,
      mail_from    => $mail_from,
      mail_to      => $mail_to,
      smtp_address => $smtp_address,
      smtp_port    => $smtp_port,
      smtp_domain  => $smtp_domain,
    },
    filters => [ 'state-change-only' ],
  }

    sensu::plugin { 'sensu-plugins-mailer':
      type => 'package'
    }
  }

  include ::profile::sensu::checks
  include ::profile::sensu::plugins
  include ::profile::sensu::plugin::http
  include ::profile::sensu::uchiwa
}
