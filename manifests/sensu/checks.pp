# Sensu check definitions
class profile::sensu::checks {
  include ::profile::sensu::checks::justforfun

  # Base checks for all hosts
  sensu::check { 'diskspace':
    command     => 'check-disk-usage.rb -w :::disk.warning|80::: -c :::disk.critical|90::: -I :::disk.mountpoints|all:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'all' ],
  }

  sensu::check { 'load':
    command     => 'check-load.rb -w :::load.warning|1,5,10::: -c :::load.critical|10,15,25:::',
    standalone  => false,
    interval    => 300,
    subscribers => [ 'all'],
  }

  sensu::check { 'memory':
    command     => 'check-memory-percent.rb -w :::memory.warning|85::: -c :::memory.critical|90:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'all' ],
  }

  # Physical servers only checks
  sensu::check { 'general-hw-error':
    command     => 'check-hardware-fail.rb',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }

  sensu::check { 'check-raid':
    command     => '/etc/sensu/plugins/extra/check_raid.pl --noraid=OK',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'physical-servers' ],
  }

  # Physical Dell Servers checks
  sensu::check { 'rac-system-event-log':
    command     => '/etc/sensu/plugins/extra/check_rac_sel.sh -h :::rac.ip::: -p :::rac.password:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'dell-servers' ],
  }

  # Ceph checks
  sensu::check { 'ceph-health':
    command     => 'sudo check-ceph.rb -d',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'roundrobin:ceph' ],
  }

  # MySQL cluster checks
  sensu::check { 'mysql-status':
    aggregate   => 'galera-cluster',
    command     => 'check-mysql-status.rb -h localhost -d mysql -u clustercheck -p :::mysql.password::: --check status',
    interval    => 300,
    handle      => false,
    standalone  => false,
    subscribers => [ 'mysql' ],
  }

  # Rabbitmq checks
  sensu::check { 'rabbitmq-alive':
    command     => 'check-rabbitmq-alive.rb',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  sensu::check { 'rabbitmq-node-health':
    command     => 'check-rabbitmq-node-health.rb -m :::rabbitmq.memwarn|80::: -c :::rabbitmq.memcrit|90::: -f :::rabbitmq.fdwarn|80::: -F :::rabbitmq.fdcrit|90::: -s :::rabbitmq.socketwarn|80::: -S :::rabbitmq.socketcrit|90:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  sensu::check { 'rabbitmq-queue-drain-time':
    command     => 'check-rabbitmq-queue-drain-time.rb -w :::rabbitmq.queuewarn|180::: -c :::rabbitmq.queuecrit|360:::',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'rabbitmq' ],
  }

  # HAProxy checks
  sensu::check { 'haproxy-stats':
    command     => 'check-haproxy.rb -S localhost -q / -P 9000 -A',
    interval    => 300,
    standalone  => false,
    subscribers => [ 'haproxy-servers' ],
  }
}
