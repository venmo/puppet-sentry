# == Class: sentry::config
#
# This class is called from sentry for service config.
#
class sentry::config
{
  $password_hash  = $sentry::password_hash
  $secret_key     = $sentry::secret_key
  $user           = $sentry::user
  $email          = $sentry::email
  $url            = $sentry::url
  $host           = $sentry::host
  $port           = $sentry::port
  $workers        = $sentry::workers
  $database       = $sentry::database
  $beacon_enabled = $sentry::beacon_enabled
  $email_enabled  = $sentry::email_enabled
  $proxy_enabled  = $sentry::proxy_enabled
  $redis_enabled  = $sentry::redis_enabled
  $extra_config   = $sentry::extra_config

  $config = {
    'database' => merge(
      $sentry::params::database_config_default,
      $sentry::database_config
    ),
    'email'    => merge(
      $sentry::params::email_config_default,
      $sentry::email_config
    ),
    'redis'    => merge(
      $sentry::params::redis_config_default,
      $sentry::redis_config
    ),
  }

  file { "${sentry::path}/sentry.conf.py":
    ensure  => present,
    content => template('sentry/sentry.conf.py.erb'),
    owner   => $sentry::owner,
    group   => $sentry::group,
    mode    => '0640',
  } ->

  file { "${sentry::path}/initial_data.json":
    ensure  => present,
    content => template('sentry/initial_data.json.erb'),
    owner   => $sentry::owner,
    group   => $sentry::group,
    mode    => '0640',
  } ~>

  sentry::command { 'postconfig_upgrade':
    command     => 'upgrade',
    refreshonly => true,
  }
}
