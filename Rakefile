# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

TYPECHECK_LEVELS = %w[normal typed strict strong].freeze

desc "Typecheck lib with Solargraph (level: #{TYPECHECK_LEVELS.join(', ')}; default: typed)"
task :typecheck, [:level] do |_task, args|
  args.with_defaults(level: 'typed')
  # Solargraph silently falls back to 'normal' for an unknown level, so fail loudly instead
  unless TYPECHECK_LEVELS.include?(args.level)
    abort "Unknown typecheck level '#{args.level}'; use one of: #{TYPECHECK_LEVELS.join(', ')}"
  end

  sh 'bundle', 'exec', 'solargraph', 'typecheck', '--level', args.level
end

task default: %i[rubocop spec]
