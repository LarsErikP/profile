# Keepalived config for management haproxy servers

# require ::profile::services::keepalived

$haproxy_mgmt_ip = hiera('profile::services::keepalived::haproxy::management::ip')
notice('Hello from profile::services::keepalived::haproxy::management')

# TODO: Complete this
