# Haproxy config for uchiwa

class profile::services::haproxy::redis {

  haproxy::listen { 'redis':
    ipaddress => '*',
    ports     => '6379',
    mode      => 'tcp',
    options   => {
      'option'    => 'tcp-check',
      'tcp-check' => [
        'connect',
        'send PING\r\n',
        'expect string +PONG',
        'send info\ replication\r\n',
        'expect string role:master',
        'send QUIT\r\n',
        'expect string +OK',
      ],
    },
  }
}
