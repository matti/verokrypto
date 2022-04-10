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

namespace :docker do
  desc 'build'
  task :build do
    sh 'docker buildx bake'
  end
  desc 'push'
  task :push do
    sh 'docker buildx bake --push'
  end
end

task default: %i[
  rubocop:auto_correct
  rubocop
  spec
]
