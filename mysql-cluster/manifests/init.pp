class mysql-cluster{

  #package {'mysql-server':ensure => present}

  class { 'corosync':
    enable_secauth    => true,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => '192.168.0.0',
    multicast_address => '239.1.1.2',
    debug             => true,
	#require			  => Package['mysql-server'],
  }

  file { '/etc/corosync/mysql.config':
    ensure => 'file',
    source  => "puppet:///modules/${module_name}/mysql.config",
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

#  file { 'crmsh':
#    name => '/root/crmsh-1.2.6-0.rc2.2.1.x86_64.rpm',
#    owner => 'root',
#    group => 'root',
#    mode => '0644',
#    source => "puppet:///modules/${module_name}/crmsh-1.2.6-0.rc2.2.1.x86_64.rpm",
#    require => Corosync::Service['pacemaker'],
#  }
#  package { 'pssh':
#    ensure => present,
#    require => File['crmsh'],
#  }

#  package { 'redhat-rpm-config':
#    ensure => present,
#    require => Package['pssh'],
#    notify => Exec['rpm crmsh'],
#  }
  exec { 'crmsh repo':
	command => 'wget -P /etc/yum.repos.d/ http://download.opensuse.org/repositories/network:/ha-clustering:/Stable/CentOS_CentOS-6/network:ha-clustering:Stable.repo',
	path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
	logoutput => on_failure,
	unless => '/bin/ls /etc/yum.repos.d/network:*',
	require => Service['pacemaker'],
  }

  package { 'crmsh':
	ensure => present,
	require => Exec['crmsh repo'],
  }
#  exec { 'rpm crmsh':
#    command => 'rpm -ivh crmsh-1.2.6-0.rc2.2.1.x86_64.rpm',
#    path => ['/usr/bin','/usr/sbin','/bin','/sbin'],
#    logoutput => on_failure,
#    require => File['crmsh'],
    #notify => Exec['load crmsh'],
#    unless => '/bin/ls /usr/sbin/crm',
#  }
}
