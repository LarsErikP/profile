# Installs and configures puppetdb on the puppetmaster.
class profile::services::puppetdb {

  class { '::java':
    distribution => 'jre',
  } ->
  class { '::puppetdb::globals':
    version => '2.3.6-1puppetlabs1',
  }
  class { '::puppetdb':
    confdir          => '/etc/puppetdb/conf.d',
    postgres_version => '9.3',
    manage_firewall  => false,
  }
  class { '::puppetdb::master::config':
    terminus_package => 'puppetdb-terminus',
  }

}
