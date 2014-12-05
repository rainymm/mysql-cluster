class mysql-cluster::config(
  $active_host = undef,
  $passive_host = undef,
  $active_ip = undef,
  $passive_ip = undef,
  $vip = undef
){

  #package {'mysql-server':ensure => present}

  $bind_address = test(hiera(openstack::network::external))
  $nic = device(hiera(openstack::network::external))

  class { 'corosync':
    enable_secauth    => true,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => $bind_address,
    multicast_address => '239.1.1.2',
    debug             => true,
	#require			  => Package['mysql-server'],
  }

  file { '/etc/corosync/mysql.config':
    ensure => 'file',
    content  => template('mysql-cluster/mysql.config.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    require => Package['pacemaker', 'corosync'],
    before  => Service['corosync'],
  }

  service { 'pacemaker':
    ensure  => stopped,
    enable  => false,
    require => Package['pacemaker'],
  }

  corosync::service { 'pacemaker':
    version => '0',
    notify  => Service['corosync'],
    require => Service['pacemaker'],
  }


  file {'my.cnf':
	name => '/etc/my.cnf',
	owner => 'root',
	group => 'root',
	mode => '0644',
	source => "puppet:///modules/${module_name}/my.cnf",
#	require => Package['mysql-server'],
  }

}
