# Load balancing for sensu services

class profile::services::redis::balancer {
  contain ::profile::services::redis::haproxy
  include ::profile::services::keepalived::haproxy::management
}
