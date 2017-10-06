# Baseconfig for all haproxy servers

class profile::services::haproxy {

  class { '::haproxy':
    merge_options    => true,
    global_options   => {
      'log' => [
        '/dev/log local0',
        '/dev/log local1 notice',
      ],
      'maxconn' => '8000',
    },
  }
}
