# Installs and configures puppetdb on the puppetmaster.
class profile::services::puppetdb {

  class { '::puppetdb': }
  class { '::puppetdb::master::config': }

}
