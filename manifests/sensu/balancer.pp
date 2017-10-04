# Load balancing for sensu services

class profile::sensu::balancer {
  contain ::profile::sensu::haproxy
  include ::profile::services::keepalived::haproxy::management
}
