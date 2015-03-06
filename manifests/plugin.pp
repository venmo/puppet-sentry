# == Define: sentry::plugin
#
# This define installs a sentry plugin.
#
# === Parameters
#
# [*plugin*]
#   The plugin to install.
#
# [*version*]
#   The plugin version to install.
#
define sentry::plugin(
  $plugin  = $title,
  $version = undef,
) {
  include sentry

  validate_string($plugin)
  validate_string($version)

  if $version {
    $pip_install_args = "-U ${plugin}==${version}"
    $pip_freeze_spec  = "${plugin}==${version}"
  } else {
    $pip_install_args = "-U ${plugin}"
    $pip_freeze_spec  = $plugin
  }

  exec { "sentry_plugin_${plugin}":
    command => "${sentry::install::pip_command} install ${pip_install_args}",
    unless  => "${sentry::install::pip_command} freeze | /bin/grep '${pip_freeze_spec}'",
    user    => $sentry::owner,
    cwd     => $sentry::path,
    timeout => $sentry::timeout,
  }
}
