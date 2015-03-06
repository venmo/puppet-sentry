require 'spec_helper'

describe 'sentry::plugin' do
  on_supported_os.each do |os, facts|
    describe "on #{os}" do
      let(:facts) do
        facts
      end
      let(:title) { 'sentry-test' }

      context 'with default parameters' do
        it { is_expected.to contain_exec('sentry_plugin_sentry-test').with(
          :command => "#{SENTRY_PIP_COMMAND} install -U sentry-test",
          :unless  => "#{SENTRY_PIP_COMMAND} freeze | /bin/grep 'sentry-test'",
          :user    => SENTRY_USER,
          :cwd     => SENTRY_PATH,
        ) }
      end

      context 'with version' do
        let(:params) {{
          :version => '0.1.0',
        }}

        it { is_expected.to contain_exec('sentry_plugin_sentry-test').with(
          :command => "#{SENTRY_PIP_COMMAND} install -U sentry-test==0.1.0",
          :unless  => "#{SENTRY_PIP_COMMAND} freeze | /bin/grep 'sentry-test==0.1.0'",
          :user    => SENTRY_USER,
          :cwd     => SENTRY_PATH,
        ) }
      end
    end
  end
end
