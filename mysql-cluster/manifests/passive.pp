class mysql-cluster::passive {
	  require ::mysql-cluster

  class { 'drbd': }

  drbd::resource { 'drbd':
    host1         => $active_host,
    host2         => $passive_host,
    ip1           => $active_ip,
    ip2           => $passive_ip,
    disk          => '/dev/sdb',
    port          => '7789',
    device        => '/dev/drbd0',
    manage        => true,
    verify_alg    => 'sha1',
    ha_primary    => false,
    initial_setup => false,
  }

  drbd::migration { '/var/lib/mysql':
    service    => 'mysqld',
    volume     => 'drbd',
    ha_primary => false,
    require    => Drbd::Resource['drbd']
  }
}
