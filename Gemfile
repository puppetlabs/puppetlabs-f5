source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :development, :test do
  gem 'rake',                    :require => false
  gem 'rspec-mocks',             :require => false
  gem 'rspec-puppet',            :require => false
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'rspec-system',            :require => false
  gem 'rspec-system-puppet',     :require => false
  gem 'rspec-system-serverspec', :require => false
  gem 'serverspec',              :require => false
  gem 'puppet-lint',             :require => false
  gem 'pry',                     :require => false
  gem 'simplecov',               :require => false
  gem 'beaker',                  :require => false
  gem 'beaker-rspec',            :require => false
  gem 'savon',                   :require => false
end

gem 'httpclient'
$: << File.expand_path('/usr/local/Cellar/rbenv/0.4.0/versions/1.9.3-p545/lib/ruby/gems/1.9.1/gems/f5-icontrol-10.2.0.2/')
begin
require 'f5-icontrol'
rescue LoadError
  puts "whatever lol"
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
