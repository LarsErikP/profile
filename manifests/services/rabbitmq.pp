# Installs and configures a rabbitmq server for our openstack environment.
class profile::services::rabbitmq {
  # Rabbit credentials
  $rabbituser = hiera('profile::rabbitmq::rabbituser')
  $rabbitpass = hiera('profile::rabbitmq::rabbitpass')
  $secret     = hiera('profile::rabbitmq::rabbitsecret')
  $rabbitservers = hiera('profile::rabbitmq::servers')
  $rabbitclustermode = hiera('profile::rabbitmq::clustermode', 'ignore')
  # Make sure keepalived is installed before rabbit.
  require ::profile::services::erlang

  class { '::rabbitmq':
    admin_enable               => false,
    config_cluster             => true,
    cluster_nodes              => $rabbitservers,
    cluster_node_type          => 'ram',
    cluster_partition_handling => $rabbitclustermode,
    erlang_cookie              => $secret,
    wipe_db_on_cookie_change   => true,
  }->
  rabbitmq_user { $rabbituser:
    admin    => true,
    password => $rabbitpass,
    provider => 'rabbitmqctl',
  } ->
  rabbitmq_user_permissions { "${rabbituser}@/":
    configure_permission => '.*',
    write_permission     => '.*',
    read_permission      => '.*',
    provider             => 'rabbitmqctl',
  }

  # Install munin plugins for monitoring.
  $installMunin = hiera('profile::munin::install', true)
  if($installMunin) {
    munin::plugin { 'rabbit_fd':
      ensure => present,
      source => 'puppet:///modules/profile/muninplugins/rabbit_fd',
      config => ['user root'],
    }
    munin::plugin { 'rabbit_processes':
      ensure => present,
      source => 'puppet:///modules/profile/muninplugins/rabbit_processes',
      config => ['user root'],
    }
    munin::plugin { 'rabbit_memory':
      ensure => present,
      source => 'puppet:///modules/profile/muninplugins/rabbit_memory',
      config => ['user root'],
    }
  }

  # Include rabbitmq configuration for sensu. And the plugin
  $installSensu = hiera('profile::sensu::install', true)
  if ($installSensu) {
    include ::profile::services::rabbitmq::sensu
    include ::profile::sensu::plugin::rabbitmq
  }

}
