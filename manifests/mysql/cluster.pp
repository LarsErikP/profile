# Configuring galera and maraidb cluster
class profile::mysql::cluster {
  # Keepalived settings
  $vrrp_password = hiera('profile::keepalived::vrrp_password')
  $vrid = hiera('profile::mysql::vrrp::id')
  $vrpri = hiera('profile::mysql::vrrp::priority')
  
  $mysql_ip = hiera('profile::mysql::ip')
  $servers = hiera('controller::management::addresses')
  $master  = hiera('profile::mysqlcluster::master')
  $rootpassword = hiera('profile::mysqlcluster::root_password')
  $statuspassword = hiera('profile::mysqlcluster::status_password')

  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")

  require profile::services::keepalived

  apt::source { 'galera_mariadb':
    location   => 'http://mariadb.cu.be/repo/10.1/ubuntu',
    repos      => 'main',
    release    => $::lsbdistcodename,
    key        => 'F1656F24C74CD1D8',
    key_server => 'keyserver.ubuntu.com',
    notify     => Exec['apt_update'],
  }

  class { '::galera' :
    galera_servers      => $servers,
    galera_master       => $master,
    galera_package_name => 'galera-3',
    mysql_package_name  => 'mariadb-server-10.1',
    client_package_name => 'mariadb-client-10.1',
    status_password     => $statuspassword,
    vendor_type         => 'mariadb',
    root_password       => $rootpassword,
    local_ip            => $management_ip,
    configure_firewall  => false,
    configure_repo      => false,
    override_options    => {
      'mysqld'          => {
        'port'            => '3306',
        'bind-address'    => $mysql_ip,
        'max_connections' => '1000',
        'wsrep_on'        => 'ON',
      }
    },
    require             => Apt::Source['galera_mariadb'],
  }

  mysql_user { "root@${master}":
    ensure  => 'absent',
    require => Class['::galera'],
  }->
  mysql_user { 'root@%':
    ensure        => 'present',
    password_hash => mysql_password($rootpassword)
  }->
  mysql_grant { 'root@%/*.*':
    ensure     => 'present',
    options    => ['GRANT'],
    privileges => ['ALL'],
    table      => '*.*',
    user       => 'root@%',
  }->
  
  keepalived::vrrp::script { 'check_mysql':
    script => '/usr/bin/killall -0 mysqld',
  }
  
  # Define the virtual addresses
  keepalived::vrrp::instance { 'management-database':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrid,
    priority          => $vrpri,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${mysql_ip}/32",
    ],
    track_script      => 'check_mysql',
  }

  # firewall
  firewall { '010 accept mysql':
    proto       => 'tcp',
    dport       => 3306,
    source      => '10.100.0.0/24',
    destination => $mysql_ip,
    action      => 'accept',
  }
  firewall { '011 accept wsrep':
    proto  => 'tcp',
    dport  => 4567,
    source => '10.100.0.0/24',
    action => 'accept',
  }
}
