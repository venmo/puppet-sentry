## 2015-09-10 Release 1.0.0

This release introduces several backward incompatible changes:

- The `password_hash` class parameter has been replaced with `password`
  which takes plain text instead of a hash
- The `user` class parameter was removed, the superuser's username is now
  the same as their email

Other changes include:

- A specific Sentry version (currently `7.7.0`) is installed by default if
  a version isn't specified

  Previously, the most recent PyPI version was installed.
  Versions older than `7.7.0` are no longer officially supported.

- Ubuntu 12.04 (Precise) is no longer officially supported, due to
  Sentry >= `7.5.0` requiring a newer Redis version than shipped
- Upgrades are no longer done automatically, but must be
  done as documented at
  [Upgrading](https://sentry.readthedocs.org/en/7.0.0/upgrading/index.html)

## 2015-03-17 Release 0.4.0

- Support for Sentry 7.4.0+
- Support for beacon added in 7.3.0

## 2015-03-05 Release 0.3.0

- Support for Sentry 7.3.0+
- Support for Sentry plugins

## 2015-01-16 Release 0.2.0

- Support for Debian 7
- Documentation fixes

## 2015-01-14 Release 0.1.0

- Initial release
