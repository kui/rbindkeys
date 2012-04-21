#!/usr/bin/env rake

require "bundler/gem_tasks"
require "rspec/core"
require "rspec/core/rake_task"

desc "Run all specs in spec/*_spec.rb"
RSpec::Core::RakeTask.new :spec

task :build => :spec
task :default => :spec
