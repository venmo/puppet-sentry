# == Class: sentry::install::python
#
class sentry::install::python
{
  $virtualenv_path = $sentry::install::virtualenv_path

  if $sentry::manage_python {
    class { '::python':
      dev        => true,
      pip        => true,
      virtualenv => true,
    } -> Package <| provider == 'pip' |>

    python::virtualenv { $virtualenv_path:
      ensure => present,
      owner  => $sentry::owner,
      group  => $sentry::group,
    }
  } else {
    exec { 'create_virtualenv':
      command => "virtualenv ${virtualenv_path}",
      creates => "${virtualenv_path}/bin/activate",
      user    => $sentry::owner,
      cwd     => $sentry::path,
      path    => '/usr/local/bin:/usr/bin',
    }
  }
}
