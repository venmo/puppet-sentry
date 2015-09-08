# == Class: sentry_profile
#
# This class wraps the Sentry module with Postgres as a database,
# Redis for caching/queueing, and nginx as a reverse SSL proxy.
#
# === Setup
#
# The nginx module is required:
#
#   puppet module install jfryman-nginx
#
# The postgresql and redis modules are required if using localhost:
#
#   puppet module install puppetlabs-postgresql
#   puppet module install fsalum-redis
#
# The SSL cert and key must be installed separately into the following paths:
#
#   /etc/ssl/certs/sentry.crt
#   /etc/ssl/private/sentry.key
#
# === Example Usage
#
#    class { 'sentry_profile':
#      version           => '7.7.0',
#      password_hash     => 'pbkdf2_sha256$20000$9tjS6wreTjar$oAdyvcOd8HCMuBpxdyvv2Cg7xz6Ee1IVz30zYUA46Wg=',
#      secret_key        => 'bxXkluWCyi7vNDDALvCKOGCI2WEbohkpF9nVPnV6jWGB1grz5csT3g==',
#      email             => 'sentry@example.com',
#      url               => 'https://sentry.example.com',
#      database_password => 'randompassword',
#    }
#
class sentry_profile(
  $version,
  $password_hash,
  $secret_key,
  $email,
  $url,
  $database_password,
  $database_host = 'localhost',
  $database_name = 'sentry',
  $database_user = 'sentry',
  $redis_host    = 'localhost',
  $ssl_cert_path = '/etc/ssl/certs/sentry.crt',
  $ssl_key_path  = '/etc/ssl/private/sentry.key',
) {

  validate_string(
    $version,
    $password_hash,
    $secret_key,
    $email,
    $database_password,
    $database_host,
    $database_name,
    $database_user,
    $redis_host,
  )
  validate_absolute_path(
    $ssl_cert_path,
    $ssl_key_path,
  )
  validate_re($url, '^https://')

  $url_domain = regsubst($url, '^https://([\w.-]+)', '\1')

  if $redis_host == 'localhost' {
    class { '::redis':
      package_ensure => present,
      before         => Class['sentry'],
    }
  }

  if $database_host == 'localhost' {
    class { '::postgresql::server':
      before => Class['sentry'],
    }

    postgresql::server::db { $database_name:
      user     => $database_user,
      password => postgresql_password($database_user, $database_password),
    }
  }

  class { '::sentry':
    version         => $version,
    password_hash   => $password_hash,
    secret_key      => $secret_key,
    email           => $email,
    url             => $url,
    database        => 'postgres',
    proxy_enabled   => true,
    redis_enabled   => true,
    database_config => {
      'host'     => $database_host,
      'name'     => $database_name,
      'user'     => $database_user,
      'password' => $database_password,
    },
    redis_config    => {
      'host' => $redis_host,
    },
  }

  class { '::nginx':
    worker_processes => $::processorcount,
  }

  nginx::resource::upstream { 'sentry_http':
    members => ['localhost:9000'],
  }

  nginx::resource::vhost { $url_domain:
    proxy            => 'http://sentry_http',
    ssl              => true,
    ssl_cert         => $ssl_cert_path,
    ssl_key          => $ssl_key_path,
    rewrite_to_https => true,
  }
}
