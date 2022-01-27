require "bundler/setup"
require "sdoc"
require "pry"
require "opt_struct"

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rdoc/task"

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

RDoc::Task.new do |t|
  t.rdoc_dir = "doc"
  t.rdoc_files.include("README.md", "lib/**/*.rb")
  t.options << "--format=sdoc"
  t.template = "rails"
end

task :console do
  Pry.start
end
