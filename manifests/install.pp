# == Class: sentry::install
#
# This class is called from sentry for install.
#
class sentry::install
{
  $extra_python_reqs = $sentry::extra_python_reqs

  $virtualenv_path   = "${sentry::path}/virtualenv"
  $pip_command       = "${virtualenv_path}/bin/pip"
  $requirements_file = "${virtualenv_path}/requirements.txt"

  if $sentry::database in ['mysql', 'postgres'] {
    $pip_install_spec = "sentry[${sentry::database}]"
  } else {
    $pip_install_spec = 'sentry'
  }

  case $sentry::source_location {
    'pypi': {
      $pip_install_args = "${pip_install_spec}==${sentry::version}"
      $pip_freeze_spec = 'sentry'
    }
    'git': {
      $pip_install_args = join([
        "-e ${sentry::git_url}@${sentry::git_revision}",
        "egg=${pip_install_spec}",
      ], '#')
      # Ideally we'd have the git revision frozen but pip doesn't support that
      $pip_freeze_spec = 'sentry'

      if $sentry::manage_git {
        class { '::git':
          before => Exec['install_sentry'],
        }
      }
      if $sentry::manage_nodejs {
        class { '::nodejs':
          manage_repo => true,
          before      => Exec['install_sentry'],
        }
      }
    }
    default: {
      fail("Source location ${sentry::source_location} not supported")
    }
  }

  ensure_packages($sentry::params::packages)

  anchor { 'sentry::install::begin': } ->

  Package[$sentry::params::packages] ->

  group { $sentry::group:
    ensure => present,
  } ->

  user { $sentry::owner:
    ensure  => present,
    comment => 'Sentry user',
    gid     => $sentry::group,
    home    => $sentry::path,
  } ->

  file { $sentry::path:
    ensure => directory,
    owner  => $sentry::owner,
    group  => $sentry::group,
    mode   => '0750',
  } ->

  class { 'sentry::install::database': } ->

  class { 'sentry::install::python': } ->

  exec { 'install_sentry':
    command => "${pip_command} install ${pip_install_args}",
    unless  => "${pip_command} freeze | /bin/grep '${pip_freeze_spec}'",
    user    => $sentry::owner,
    cwd     => $sentry::path,
    timeout => $sentry::timeout,
  } ->

  file { $requirements_file:
    ensure  => present,
    content => template('sentry/requirements.txt.erb'),
  } ~>

  exec { 'install_requirements':
    command     => "${pip_command} install -r ${requirements_file}",
    refreshonly => true,
    user        => $sentry::owner,
    cwd         => $sentry::path,
    timeout     => $sentry::timeout,
  } ->

  anchor { 'sentry::install::end': }
}
