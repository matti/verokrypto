# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'

RuboCop::RakeTask.new
RSpec::Core::RakeTask.new(:spec)

desc 'run e2e test'
task :e2e do
  sh 'e2e/main.sh'
end

task default: %i[
  rubocop:auto_correct
  rubocop
  spec
  e2e
]
