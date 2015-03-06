require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

SENTRY_PATH    = '/srv/sentry'
SENTRY_USER    = 'sentry'

SENTRY_VENV_PATH   = "#{SENTRY_PATH}/virtualenv"
SENTRY_COMMAND     = "#{SENTRY_VENV_PATH}/bin/sentry --config=#{SENTRY_PATH}/sentry.conf.py"
SENTRY_PIP_COMMAND = "#{SENTRY_VENV_PATH}/bin/pip"

RSpec.configure do |c|
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end

  c.default_facts = {
    :concat_basedir => '/var/lib/puppet/concat'
  }
end
