# This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::packages

  #  Firewall {
  #  before  => Class['profile::baseconfig::firewall_post'],
  #  require => Class['profile::baseconfig::firewall_pre'],
  #}
  include ::profile::baseconfig::firewall_pre
  include ::profile::baseconfig::firewall_post
}
