# Sensu check definitions
class profile::sensu::checks {
  include ::profile::sensu::checks::justforfun

  include ::profile::sensu::checks::base
  include ::profile::sensu::checks::ceph
  include ::profile::sensu::checks::dell
  include ::profile::sensu::checks::haproxy
  include ::profile::sensu::checks::mysql
  include ::profile::sensu::checks::physical
  include ::profile::sensu::checks::rabbitmq

}
