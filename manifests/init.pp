# == Class: sentry
#
# This class installs, configures, and manages the
# Sentry[https://sentry.readthedocs.org/] realtime event logging and
# aggregation platform.
#
# === Parameters
#
# [*path*]
#   The absolute path under which to install Sentry, defaults to `/srv/sentry`.
#
# [*owner*]
#   The owner for Sentry files, defaults to `sentry`.
#
# [*group*]
#   The group for Sentry files, defaults to `sentry`.
#
# [*source_location*]
#   The source location from which to install Sentry.
#   Choose from:
#
#   [pypi] PyPI (Default)
#   [git]  Git
#
# [*version*]
#   The Sentry version to install if using PyPI, defaults to `latest`.
#
# [*git_revision*]
#   The Sentry revision to install if using Git, defaults to `master`.
#   Can be branch, tag, or commit sha1.
#
# [*git_url*]
#   The URL to install Sentry from if using Git, defaults to
#   `git+https://github.com/getsentry/sentry.git`.
#
# [*timeout*]
#   The timeout for install commands, defaults to `1800` seconds.
#
# [*manage_git*]
#   Whether to manage git if needed for install, defaults to `true`. If `false`,
#   git is expected to be preinstalled.
#
# [*manage_nodejs*]
#   Whether to manage nodejs if needed for compiling static assets during
#   git install, defaults to `true`. If `false`, nodejs and npm are expected
#   to be preinstalled.
#
# [*manage_python*]
#   Whether to manage Python for running Sentry, defaults to `true`. If `false`,
#   python (w/ dev package), pip, and virtualenv are expected to be
#   preinstalled.
#
# [*extra_python_reqs*]
#   Extra Python requirements to install, in addition to and/or instead of
#   what's specified in setup.py.
#
# [*password_hash*]
#   The password hash for Sentry's admin user, defaults to password hash for
#   `password`. Should be a PBKDF2-HMAC-SHA256 hash generated as shown at
#   https://pythonhosted.org/passlib/lib/passlib.hash.django_std.html#django-1-4-hashes.
#
# [*secret_key*]
#   The secret key to use, should be a randomly generated 40-160 byte string.
#
# [*user*]
#   The username for the Sentry admin user, defaults to `admin`.
#
# [*email*]
#   The email address for the Sentry admin user, defaults to `root@localhost`.
#
# [*url*]
#   The absolute URL to access Sentry, defaults to `http://localhost:9000`.
#   Must not have a trailing slash.
#
# [*host*]
#   The hostname which the webserver should bind to, defaults to `localhost`.
#
# [*port*]
#   The port which the webserver should listen on, defaults to `9000`.
#
# [*workers*]
#   The number of gunicorn workers to start, default is calculated according
#   to number of cores.
#
# [*database*]
#   The database to use.
#   Choose from:
#
#   [sqlite]    SQLite DB (Default)
#   [mysql]     MySQL DB
#   [postgres]  Postgres DB
#
# [*email_enabled*]
#   Whether to enable support for sending email notifications, defaults
#   to `false`.
#
# [*proxy_enabled*]
#   Whether to enable support for serving behind a reverse proxy, defaults
#   to `false`.
#
# [*redis_enabled*]
#   Whether to enable Redis support for caching and queueing worker jobs,
#   defaults to false.
#
# [*database_config*]
#   A hash with the database configuration, not needed for SQLite.
#   Can include:
#
#   [name]      Database name (defaults to `sentry`)
#   [user]      Database user
#   [password]  Database password
#   [host]      Database host (`defaults to localhost`)
#   [port]      Database port (defaults to IANA registered port)
#
# [*email_config*]
#   A hash with the email configuration, only needed if enabled.
#   Can include:
#
#   [host]      SMTP host (defaults to `localhost`)
#   [port]      SMTP port (defaults to `25`)
#   [user]      SMTP user
#   [password]  SMTP password
#   [use_tls]   Whether to enable SMTP TLS (defaults to `false`)
#   [from_addr] The from address (defaults to admin email)
#
# [*redis_config*]
#   A hash with the Redis configuration, only needed if enabled.
#   Can include:
#
#   [host]      Redis host (defaults to `localhost`)
#   [port]      Redis port (defaults to `6379`)
#
# [*extra_config*]
#   Extra configuration to append to Sentry config, can be array or string.
#
# [*service_restart*]
#   Whether to restart Sentry on config change, defaults to `true`.
#
class sentry(
  # Install params
  $path              = $sentry::params::path,
  $owner             = $sentry::params::owner,
  $group             = $sentry::params::group,
  $source_location   = $sentry::params::source_location,
  $version           = $sentry::params::version,
  $git_revision      = $sentry::params::git_revision,
  $git_url           = $sentry::params::git_url,
  $timeout           = $sentry::params::timeout,
  $manage_git        = true,
  $manage_nodejs     = true,
  $manage_python     = true,
  $extra_python_reqs = [],
  # Config params
  $password_hash   = $sentry::params::password_hash,
  $secret_key      = $sentry::params::secret_key,
  $user            = $sentry::params::user,
  $email           = $sentry::params::email,
  $url             = $sentry::params::url,
  $host            = $sentry::params::host,
  $port            = $sentry::params::port,
  $workers         = $sentry::params::workers,
  $database        = $sentry::params::database,
  $email_enabled   = false,
  $proxy_enabled   = false,
  $redis_enabled   = false,
  $database_config = {},
  $email_config    = {},
  $redis_config    = {},
  $extra_config    = [],
  # Service params
  $service_restart = true,
) inherits sentry::params {

  validate_re($source_location, ['^git$', '^pypi$'])
  validate_re($database, ['^mysql$', '^postgres$', '^sqlite$'])
  validate_string(
    $version,
    $git_revision,
    $git_url,
    $password_hash,
    $email,
    $url,
    $user,
    $owner,
    $group,
    $host,
  )
  validate_slength($secret_key, 160, 40)  # the maximum size of 160 is arbitrary
  validate_absolute_path($path)
  validate_bool(
    $manage_git,
    $manage_nodejs,
    $manage_python,
    $email_enabled,
    $proxy_enabled,
    $redis_enabled,
    $service_restart,
  )
  validate_array(
    $extra_python_reqs,
  )
  validate_hash(
    $database_config,
    $email_config,
    $redis_config,
  )
  if !is_integer($timeout) { fail("Invalid timeout: ${timeout}") }
  if !is_integer($port) { fail("Invalid port: ${port}") }
  if !is_integer($workers) { fail("Invalid workers: ${workers}") }
  if is_array($extra_config) {
    validate_array($extra_config)
  } else {
    validate_string($extra_config)
  }

  if $host != $sentry::params::host and
      $password_hash == $sentry::params::password_hash {
    notify { 'Password hash unchanged from default, this is a security risk!': }
  }
  if $host != $sentry::params::host and
      $secret_key == $sentry::params::secret_key {
    notify { 'Secret key unchanged from default, this is a security risk!': }
  }
  if $version and (
      versioncmp($version, '7.0.0') < 0 or versioncmp($version, '8.0.0') >= 0
  ) {
    notify { 'Only Sentry 7.x.x is supported, use at own risk!': }
  }

  anchor { 'sentry::begin': } ->
  class { 'sentry::install': } ->
  class { 'sentry::config': } ~>
  class { 'sentry::service': } ->
  anchor { 'sentry::end': }
}
