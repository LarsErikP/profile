# Install and configure uchiwa and the apache vhost for it
class profile::sensu::uchiwa {

  require profile::services::apache

  $password = hiera('profile::sensu::uchiwa::password')
  $api_name = 'sensu-lab'
  $uchiwa_url = hiera('profile::sensu::uchiwa::fqdn')

  $management_if = hiera('profile::interfaces::management')

  class { '::uchiwa':
    user                => 'sensu',
    pass                => $password,
    install_repo        => false,
    sensu_api_endpoints => [{
      name    => $api_name,
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
    access_log_env_var  => 'forwarded'
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

}
