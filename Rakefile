require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'opal/rspec/rake_task'
require "pry"

Opal::RSpec::RakeTask.new(:opal) do |server, task|
  server.append_path 'lib'
end

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
