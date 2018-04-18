require 'rake'
require 'bundler/gem_tasks'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

RSpec::Core::RakeTask.new(:features) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/features/**/*_spec.rb']
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task :clean do
  puts 'Cleaning old coverage'
  FileUtils.rm('coverage.data') if File.exist?('coverage.data')
  FileUtils.rm_r('coverage') if File.exist?('coverage')
  FileUtils.rm_r('spec/fixtures/derivatives') if File.exist?('spec/fixtures/derivatives')
end

task :default => %i[spec rubocop]
