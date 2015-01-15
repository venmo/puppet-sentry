# == Class: sentry::params

# This class is meant to be called from sentry.
# It sets variables according to platform.
#
class sentry::params
{
  # Platform params
  case $::osfamily {
    'Debian': {
      $packages = [
        # Next three needed by lxml python library
        'libxml2-dev',
        'libxslt1-dev',
        'zlib1g-dev',
      ]

      $mysql_packages = [
        'libmysqlclient-dev',
      ]

      $postgres_packages = [
        'libpq-dev',
      ]
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  # Install params
  $path            = '/srv/sentry'
  $owner           = 'sentry'
  $group           = 'sentry'
  $source_location = 'pypi'
  $version         = undef  # indicates latest pypi version
  $git_revision    = 'master'
  $git_url         = 'git+https://github.com/getsentry/sentry.git'
  $timeout         = 1800

  # Config params
  $password_hash = 'pbkdf2_sha256$20000$9tjS6wreTjar$oAdyvcOd8HCMuBpxdyvv2Cg7xz6Ee1IVz30zYUA46Wg='
  $secret_key    = 'bxXkluWCyi7vNDDALvCKOGCI2WEbohkpF9nVPnV6jWGB1grz5csT3g=='
  $user          = 'admin'
  $email         = 'root@localhost'
  $url           = 'http://localhost:9000'
  $host          = 'localhost'
  $port          = 9000
  # http://gunicorn-docs.readthedocs.org/en/latest/design.html#how-many-workers
  $workers       = ($::processorcount * 2) + 1
  $database      = 'sqlite'

  $database_config_default = {
    'name'     => 'sentry',
    'user'     => '',
    'password' => '',
    'host'     => 'localhost',
    'port'     => '',  # allow django to choose default port
  }
  $email_config_default = {
    'host'      => 'localhost',
    'port'      => 25,
    'user'      => '',
    'password'  => '',
    'use_tls'   => false,
    'from_addr' => $email,
  }
  $redis_config_default = {
    'host' => 'localhost',
    'port' => 6379,
  }
}
