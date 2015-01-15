require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

SENTRY_PATH    = '/srv/sentry'
SENTRY_USER    = 'sentry'
SENTRY_COMMAND = "#{SENTRY_PATH}/virtualenv/bin/sentry --config=#{SENTRY_PATH}/sentry.conf.py"

RSpec.configure do |c|
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end

  c.default_facts = {
    :concat_basedir => '/var/lib/puppet/concat'
  }
end
