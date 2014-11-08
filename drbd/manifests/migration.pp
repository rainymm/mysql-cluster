define drbd::migration (
  $ha_primary,
  $service,
  $volume
) {

  Exec {
    path => ['/sbin', '/bin', '/usr/sbin', '/usr/bin']
  }

  exec { "stop ${service} for drbd migration":
    command => "service ${service} stop",
    # this should probably be more precise. If we're not linked into the
    # drbd volume we still would need to migrate
    unless  => "test -L ${name}",
    require => Drbd::Resource[$volume]
  }

  if $ha_primary {
		    exec { "move ${service} data on primary node":
      command     => "mv ${name} /var/lib/cluster",
      unless => '/bin/ls /var/lib/cluster/mysql',
      require   => Exec["stop ${service} for drbd migration"],
      #before      => File[$name],
      #refreshonly => true
    }

        exec { 'load crmsh':
           command => 'crm configure load update /etc/corosync/mysql.config',
           path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
           logoutput => on_failure,
           require => Exec["move ${service} data on primary node"],
     }
  #  exec { "start ${service} after drbd migration":
  #    command     => "service ${service} start",
  #    require => Exec['load crmsh'],
  #  }

  } else {

    exec { "remove ${service} data on secondary node":
      command     => "rm -rf ${name}",
      onlyif => '/bin/ls /var/lib/mysql',
      require   => Exec["stop ${service} for drbd migration"],
      #before      => File[$name],
      #refreshonly => true
    }
  }
 
}
