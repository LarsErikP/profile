# Load balancing for sensu services

class profile::sensu::balancer {
  contain ::profile::sensu::haproxy
  contain ::profile::services::keepalived::haproxy::management
}
