class mysql-cluster::deploy(
  $active_host = undef,
  $passive_host = undef,
  $active_ip = undef,
  $passive_ip = undef,
  $disk =undef,
  $state = undef
) {
  class { 'drbd':
    notify => Drbd::Resource['drbd']
  }

  drbd::resource { 'drbd':
    host1         => $active_host,
    host2         => $passive_host,
    ip1           => $active_ip,
    ip2           => $passive_ip,
    disk          => $disk,
    port          => '7789',
    device        => '/dev/drbd0',
    manage        => true,
    verify_alg    => 'sha1',
    ha_primary    => $state,
    initial_setup => $state,
    notify        => Drbd::Migration['/var/lib/mysql']
  }

  drbd::migration { '/var/lib/mysql':
    service    => 'mysqld',
    volume     => 'drbd',
    ha_primary => $state,
    require    => Drbd::Resource['drbd']
  }	
}
