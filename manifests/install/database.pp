# == Class: sentry::install::database
#
class sentry::install::database
{
  case $sentry::database {
    'mysql': {
      ensure_packages($sentry::params::mysql_packages)
    }
    'postgres': {
      ensure_packages($sentry::params::postgres_packages)
    }
    'sqlite': {
      # Precreate the database file with secure permissions
      file { "${sentry::path}/sentry.db":
        ensure => present,
        owner  => $sentry::owner,
        group  => $sentry::group,
        mode   => '0640',
      }
    }
    default: {
      fail('Please specify a supported database from mysql,postgres,sqlite')
    }
  }
}
