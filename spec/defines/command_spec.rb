require 'spec_helper'

describe 'sentry::command' do
  on_supported_os.each do |os, facts|
    describe "on #{os}" do
      let(:facts) do
        facts
      end
      let(:title) { 'test' }

      context 'with default parameters' do
        let(:params) {{ :command => 'test' }}

        it { is_expected.to contain_exec('sentry_command_test').with(
          :command     => "#{SENTRY_COMMAND} test",
          :user        => SENTRY_USER,
          :refreshonly => false,
        ) }
      end

      context 'with refreshonly' do
        let(:params) {{
          :command     => 'test',
          :refreshonly => true,
        }}

        it { is_expected.to contain_exec('sentry_command_test').with(
          :command     => "#{SENTRY_COMMAND} test",
          :user        => SENTRY_USER,
          :refreshonly => true,
        ) }
      end
    end
  end
end
