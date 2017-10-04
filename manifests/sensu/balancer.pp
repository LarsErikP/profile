# Load balancing for sensu services

class profile::sensu::balancer {
  contain ::profile::sensu::haproxy
  require ::profile::services::keepalived::haproxy::management
}
