class mysql-cluster(
  $active_host = undef,
  $passive_host = undef,
  $active_ip = undef,
  $passive_ip = undef,
  $vip = undef,
  $disk = undef,
  $state = undef
){
  anchor { 'mysql-cluster::begin': } ->
  class { 'mysql-cluster::config':
    active_host => $active_host,
    passive_host => $passive_host,
    active_ip => $active_ip,
    passive_ip => $passive_ip,
    vip => $vip
  } ~>
  class { 'mysql-cluster::deploy':
    active_host => $active_host,
    passive_host => $passive_host,
    active_ip => $active_ip,
    passive_ip => $passive_ip,
    disk => $disk,
    state => $state
  } ->
  anchor { 'mysql-cluster::end': }
}

