# == Define: sentry::command
#
# This define executes sentry commands.
#
# === Parameters
#
# [*command*]
#   The command to execute including any arguments.
#
# [*refreshonly*]
#   Whether to execute only only when an event is received, defaults to `false`.
#
define sentry::command(
  $command,
  $refreshonly = false,
) {
  include sentry

  validate_string($command)
  validate_bool($refreshonly)

  exec { "sentry_command_${title}":
    command     => join([
      "${sentry::path}/virtualenv/bin/sentry",
      "--config=${sentry::path}/sentry.conf.py",
      $command
    ], ' '),
    user        => $sentry::owner,
    refreshonly => $refreshonly,
  }
}
