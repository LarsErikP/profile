# Install and configure uchiwa and the apache vhost for it
class profile::sensu::uchiwa {

  require profile::services::apache
  require profile::services::keepalived

  $password = hiera('profile::sensu::uchiwa::password')
  $api_name = 'sensu-lab'
  $uchiwa_url = hiera('profile::sensu::uchiwa::fqdn')

  $vrrp_id = hiera('profile::uchiwa::vrrp::id')
  $vrrp_priority = hiera('profile::uchiwa::vrrp::priority')
  $vrrp_password = hiera('profile::keepalived::vrrp_password')

  $management_if = hiera('profile::interfaces::management')

  $uchiwa_ip = hiera('profile::uchiwa::vrrp::admin::ip')
  $sensu_ip  = hiera('profile::sensu::vrrp::admin::ip')

  class { '::uchiwa':
    user                => 'sensu',
    pass                => $password,
    install_repo        => false,
    sensu_api_endpoints => [{
      name    => $api_name,
      host    => $sensu_ip,
      user    => '',
      pass    => '',
      timeout => 10,
    }],
  }

  include ::apache::mod::proxy
  include ::apache::mod::proxy_html

  apache::vhost { "${uchiwa_url} http":
    servername          => $uchiwa_url,
    serveraliases       => [$uchiwa_url],
    port                => 80,
    docroot             => false,
    manage_docroot      => false,
    proxy_preserve_host => true,
    proxy_pass          => [
      {
        'path' => '/',
        'url'  => 'http://127.0.0.1:3000/',
      },
      {
        'path' => '/socket.io/1/websocket',
        'url'  => 'ws://127.0.0.1:3000/socket.io/1/websocket',
      },
      {
        'path' => '/socket.io/',
        'url'  => 'http://127.0.0.1:3000/socket.io/',
      },
    ],
    custom_fragment     => '
    ProxyHTMLEnable On
    ProxyHTMLURLMap http://127.0.0.1:3000/ /',
  }

  keepalived::vrrp::script { 'check_uchiwa':
    script => '/usr/bin/killall -0 apache2',
  }

  keepalived::vrrp::instance { 'mgmt-uchiwa':
    interface         => $management_if,
    state             => 'MASTER',
    virtual_router_id => $vrrp_id,
    priority          => $vrrp_priority,
    auth_type         => 'PASS',
    auth_pass         => $vrrp_password,
    virtual_ipaddress => [
      "${uchiwa_ip}/32",
    ],
    track_script      => 'check_uchiwa',
  }
}
