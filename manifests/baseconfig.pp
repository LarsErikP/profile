#This class ensures that all baseconfiguration are brought in.
class profile::baseconfig {
  #  include ::profile::baseconfig::puppet
  include ::profile::baseconfig::networking
  include ::profile::baseconfig::packages
  include ::profile::baseconfig::unattendedupgrades
  include ::profile::baseconfig::ntp
  include ::profile::baseconfig::ssh
  include ::profile::baseconfig::users
  #  Firewall {
  #  before  => Class['profile::baseconfig::firewall_post'],
  #  require => Class['profile::baseconfig::firewall_pre'],
  #}
  include ::profile::baseconfig::firewall_pre
  include ::profile::baseconfig::firewall_post

  $installSensu = hiera('profile::sensu::install', true)
    if ($::hostname !~ /^sensu/ and $installSensu) {
      include ::profile::sensu::client
    }
}
