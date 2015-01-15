notification :off

guard 'rake', :task => 'spec_prep' do
  watch('.fixture.yml')
end

guard 'rake', :task => 'test:standalone' do
  watch(%r{^manifests/(.+)\.pp$})
end

guard 'rake', :task => 'metadata' do
  watch('metadata.json')
end
