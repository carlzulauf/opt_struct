require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :doc do
  `sdoc lib`
end

task :console do
  require 'opt_struct'
  require 'pry'
  Pry.start
end
