require 'spec_helper'

describe 'sentry' do
  on_supported_os.each do |os, facts|
    describe "on #{os}" do
      let(:facts) do
        facts
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('sentry') }
        it { is_expected.to contain_class('sentry::params') }
        it { is_expected.to contain_class('sentry::install')
             .that_comes_before('sentry::config') }
        it { is_expected.to contain_class('sentry::config')
             .that_notifies('sentry::service') }
        it { is_expected.to contain_class('sentry::service') }
      end

      describe 'sentry::install' do
        context 'with default parameters' do
          it { is_expected.to contain_group('sentry')
               .that_comes_before('User[sentry]') }

          it { is_expected.to contain_user('sentry').with_gid('sentry')
               .that_comes_before("File[#{SENTRY_PATH}]") }

          it { is_expected.to contain_file(SENTRY_PATH).with(
            :owner => SENTRY_USER,
            :group => SENTRY_USER,
          ).that_comes_before('Class[sentry::install::database]') }

          it { is_expected.to contain_class('sentry::install::database')
               .that_comes_before('Class[sentry::install::python]') }

          it { is_expected.to contain_class('sentry::install::python')
               .that_comes_before('Exec[install_sentry]') }

          it { is_expected.to contain_exec('install_sentry').with(
            :command => "#{SENTRY_PIP_COMMAND} install -U sentry",
            :unless  => "#{SENTRY_PIP_COMMAND} freeze | /bin/grep 'sentry'",
            :user    => SENTRY_USER,
            :cwd     => SENTRY_PATH,
          ).that_comes_before("File[#{SENTRY_VENV_PATH}/requirements.txt]") }

          it { is_expected.to contain_file("#{SENTRY_VENV_PATH}/requirements.txt")
               .that_notifies('Exec[install_requirements]') }

          it { is_expected.to contain_exec('install_requirements').with(
            :command => "#{SENTRY_PIP_COMMAND} install -r #{SENTRY_VENV_PATH}/requirements.txt",
            :user    => SENTRY_USER,
            :cwd     => SENTRY_PATH,
          ) }
        end

        context 'with version' do
          let(:params) {{ :version => '4.2.0' }}

          it { is_expected.to contain_exec('install_sentry').with(
            :command => "#{SENTRY_PIP_COMMAND} install -U sentry==4.2.0",
            :unless  => "#{SENTRY_PIP_COMMAND} freeze | /bin/grep 'sentry==4.2.0'",
          ) }
        end

        context 'with database => postgres' do
          let(:params) {{ :database => 'postgres' }}

          it { is_expected.to contain_exec('install_sentry').with(
            :command => "#{SENTRY_PIP_COMMAND} install -U sentry[postgres]",
            :unless  => "#{SENTRY_PIP_COMMAND} freeze | /bin/grep 'sentry'",
          ) }
        end

        context 'with source_location => git' do
          let(:params) {{ :source_location => 'git' }}

          it { is_expected.to contain_class('git') }
          it { is_expected.to contain_class('nodejs') }

          it { is_expected.to contain_exec('install_sentry').with(
            :command => "#{SENTRY_PIP_COMMAND} install -e git+https://github.com/getsentry/sentry.git@master#egg=sentry",
            :unless  => "#{SENTRY_PIP_COMMAND} freeze | /bin/grep 'sentry'",
          ) }
        end

        context 'with source_location => git and manage_git => false' do
          let(:params) {{
            :source_location => 'git',
            :manage_git      => false,
          }}

          it { is_expected.not_to contain_class('git') }
        end

        context 'with source_location => git and manage_nodejs => false' do
          let(:params) {{
            :source_location => 'git',
            :manage_nodejs   => false,
          }}

          it { is_expected.not_to contain_class('nodejs') }
        end

        context 'with source_location => git and database => postgres' do
          let(:params) {{
            :source_location => 'git',
            :database        => 'postgres',
          }}

          it { is_expected.to contain_exec('install_sentry').with(
            :command => "#{SENTRY_PIP_COMMAND} install -e git+https://github.com/getsentry/sentry.git@master#egg=sentry[postgres]",
          ) }
        end

        context 'with extra_python_reqs' do
          let(:params) {{
            :extra_python_reqs => [
              'foo==4.2.0',
              'bar==2.4.2',
            ],
          }}

          it { is_expected.to contain_file("#{SENTRY_VENV_PATH}/requirements.txt")
               .with_content("foo==4.2.0\nbar==2.4.2\n") }
        end
      end

      describe 'sentry::install::database' do
        context 'with default parameters' do
          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.db").with(
            :owner => SENTRY_USER,
            :group => SENTRY_USER,
          ) }
        end
      end

      describe 'sentry::install::python' do
        context 'with default parameters' do
          it { is_expected.to contain_class('python') }

          it { is_expected.to contain_python__virtualenv(SENTRY_VENV_PATH).with(
            :owner => SENTRY_USER,
            :group => SENTRY_USER,
          ) }
        end

        context 'with manage_python => false' do
          let(:params) {{ :manage_python => false }}

          it { is_expected.not_to contain_class('python') }

          it { is_expected.not_to contain_python__virtualenv(SENTRY_VENV_PATH) }

          it { is_expected.to contain_exec('create_virtualenv').with(
            :command => "virtualenv #{SENTRY_VENV_PATH}",
            :creates => "#{SENTRY_VENV_PATH}/bin/activate",
            :user    => SENTRY_USER,
            :cwd     => SENTRY_PATH,
          ) }
        end
      end

      describe 'sentry::config' do
        context 'with default parameters' do
          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py").with(
            :owner => SENTRY_USER,
            :group => SENTRY_USER,
          )
          .with_content(/'ENGINE': 'django.db.backends.sqlite3'/)
          .with_content(%r{SENTRY_URL_PREFIX = 'http://localhost:9000'})
          .with_content(/SENTRY_WEB_HOST = 'localhost'/)
          .with_content(/SENTRY_WEB_PORT = 9000/)
          .with_content(/SECRET_KEY = 'bxXkluWCyi7vNDDALvCKOGCI2WEbohkpF9nVPnV6jWGB1grz5csT3g=='/)
          .with_content(/SENTRY_ADMIN_EMAIL = 'root@localhost'/)
          .with_content(/SENTRY_BEACON = True/)
          .with_content(/SENTRY_CACHE = 'sentry.cache.django.DjangoCache'/)
          .with_content(/'workers': 3/)
          .that_comes_before("File[#{SENTRY_PATH}/initial_data.json]") }

          it { is_expected.to contain_file("#{SENTRY_PATH}/initial_data.json").with(
            :owner => SENTRY_USER,
            :group => SENTRY_USER,
          )
          .with_content(/"password": "pbkdf2_sha256\$20000\$9tjS6wreTjar\$oAdyvcOd8HCMuBpxdyvv2Cg7xz6Ee1IVz30zYUA46Wg="/)
          .with_content(/"email": "root@localhost"/)
          .with_content(/"username": "admin"/)
          .that_notifies('Sentry::Command[postconfig_upgrade]') }

          it { is_expected.to contain_sentry__command('postconfig_upgrade') }
        end

        context 'with database => mysql' do
          let(:params) {{ :database => 'mysql' }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/'ENGINE': 'django.db.backends.mysql'/) }
        end

        context 'with database => postgres' do
          let(:params) {{ :database => 'postgres' }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/'ENGINE': 'django.db.backends.postgresql_psycopg2'/) }
        end

        context 'with beacon_enabled => false' do
          let(:params) {{ :beacon_enabled => false }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/SENTRY_BEACON = False/) }
        end

        context 'with email_enabled => true' do
          let(:params) {{ :email_enabled => true }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'/) }
        end

        context 'with proxy_enabled => true' do
          let(:params) {{ :proxy_enabled => true }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/SECURE_PROXY_SSL_HEADER = \('HTTP_X_FORWARDED_PROTO', 'https'\)/)
               .with_content(/USE_X_FORWARDED_HOST = True/) }
        end

        context 'with redis_enabled => true' do
          let(:params) {{ :redis_enabled => true }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/SENTRY_CACHE = 'sentry.cache.redis.RedisCache'/)
               .with_content(/CELERY_ALWAYS_EAGER = False/)
               .with_content(%r{BROKER_URL = 'redis://localhost:6379/2'}) }
        end

        context 'with extra_config as string' do
          let(:params) {{ :extra_config => 'Insert extra config here' }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/^Insert extra config here$/) }
        end

        context 'with extra_config as array' do
          let(:params) {{
            :extra_config => [
              'Insert extra config here',
              'And here as well',
            ]
          }}

          it { is_expected.to contain_file("#{SENTRY_PATH}/sentry.conf.py")
               .with_content(/^Insert extra config here$/)
               .with_content(/^And here as well$/) }
        end
      end

      describe 'sentry::service' do
        context 'with default parameters' do

          it { is_expected.to contain_supervisord__program('sentry-http').with(
            :command   => "#{SENTRY_COMMAND} start http",
            :user      => SENTRY_USER,
            :directory => SENTRY_PATH,
          ) }

          it { is_expected.to contain_supervisord__program('sentry-worker').with(
            :command   => "#{SENTRY_COMMAND} celery worker -B",
            :user      => SENTRY_USER,
            :directory => SENTRY_PATH,
          ) }

          it { is_expected.to contain_supervisord__supervisorctl('sentry_reload')
               .that_subscribes_to('Anchor[sentry::service::begin]') }
        end

        context 'with service_restart => false' do
          let(:params) {{ :service_restart => false }}

          it { is_expected.to_not contain_supervisord__supervisorctl('sentry_reload') }
        end
      end
    end
  end

  describe 'on unsupported operating system' do
    let(:facts) {{
      :osfamily        => 'Solaris',
      :operatingsystem => 'Nexenta',
    }}

    context 'with default parameters' do
      it { expect { is_expected.to contain_class('sentry') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
