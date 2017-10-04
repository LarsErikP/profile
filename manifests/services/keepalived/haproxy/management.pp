# Keepalived config for management haproxy servers

require ::profile::services::keepalived

$ip = hiera('profile::haproxy::management::ip')
$vrrp_id = hiera('profile::haproxy::management::vrrp::id')
$vrrp_priority = hiera('profile::haproxy::management::vrrp:priority')
$vrrp_password = hiera('profile::keepalived::vrrp_password')

notice('Hello from profile::services::keepalived::haproxy::management')

# TODO: Complete this
