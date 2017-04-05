guard :bundler do
  require 'guard/bundler'
  require 'guard/bundler/verify'
  helper = Guard::Bundler::Verify.new
  files = ['Gemfile']
  files += Dir['*.gemspec'] if files.any?{|f| helper.uses_gemspec?(f)}
  files.each { |file| watch(helper.real_path(file)) }
end

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^scripts/(.+)\.rb$}){|m| "spec/#{m[1]}_spec.rb"}
  watch('spec/spec_helper.rb')  { 'spec' }
end
