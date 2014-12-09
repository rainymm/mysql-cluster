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


  file {'mysql.cnf':
    name => '/root/my.cnf',
    mode => '0644',
    source => "puppet:///modules/${module_name}/my.cnf",
    notify => Exec['mv my.cnf'],
    require => Package['mysql-server'],
  }

  exec {'mv my.cnf':
   command => 'mv /root/my.cnf /etc/my.cnf',
   path => ['usr/bin', 'usr/sbin', '/bin', '/sbin'],
   require => File['mysql.cnf']
  }  
} 
