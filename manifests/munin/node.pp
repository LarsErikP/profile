# Defines a generic munin node
class profile::munin::node {
  $management_if = hiera('profile::interfaces::management')
  $management_ip = getvar("::ipaddress_${management_if}")
  $monitor_ip    = hiera('monitor::management::addresses')
  $manageFirewall = hiera('profile::baseconfig::managefirewall', false)

  if ($manageFirewall) {
    require ::firewall

    firewall { '020 accept munin-node':
      proto  => 'tcp',
      dport  => 4949,
      action => 'accept',
    }
  }


  include ::profile::munin::plugins
  include ::profile::munin::plugin::puppet

  class {'::munin::node':
    bind_address   => $management_ip,
    allow          => $monitor_ip,
    purge_configs  => true,
    service_ensure => 'running',
  }

}
