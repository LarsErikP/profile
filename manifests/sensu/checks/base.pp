# Base checks for all nodes
class profile::sensu::checks::base {
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
}
