class drbd::service {
  @service { 'drbd':
    ensure  => running,
    enable  => true,
    require => Package['drbd84-utils'],
    restart => 'service drbd reload',
  }
}
