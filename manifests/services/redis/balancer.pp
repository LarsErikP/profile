# Load balancing for sensu services

class profile::services::redis::balancer {
  contain ::profile::services::redis::haproxy
  require ::profile::services::keepalived::haproxy::management
}
