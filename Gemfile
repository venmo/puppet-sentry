source ENV['GEM_SOURCE'] || "https://rubygems.org"

if facterversion = ENV['FACTER_VERSION']
  gem "facter", facterversion, :require => false
else
  gem "facter", :require => false
end

if puppetversion = ENV['PUPPET_VERSION']
  gem "puppet", puppetversion, :require => false
else
  gem "puppet", :require => false
end

group :unit_tests do
  gem "rspec-puppet", :git => "https://github.com/rodjek/rspec-puppet.git", :require => false

  gem "metadata-json-lint",     :require => false
  gem "puppetlabs_spec_helper", :require => false
  gem "rspec-puppet-facts",     :require => false
end

group :system_tests do
  gem "beaker-rspec", :require => false
end

group :development do
  gem "guard-rake",        :require => false
  gem "puppet-blacksmith", :require => false
  gem "travis",            :require => false
  gem "travis-lint",       :require => false
end
