# testing testing 1 2 3
class profile::sensu::checks::justforfun {
  sensu::check { 'flaptest':
    command             => 'check-process.rb -p sleep',
    interval            => 15,
    standalone          => false,
    subscribers         => [ 'flaptest' ],
    low_flap_threshold  => 20,
    high_flap_threshold => 50,
  }
}
