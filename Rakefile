require "bundler/setup"
require "opt_struct"

require "bundler/gem_tasks"
require "rspec/core/rake_task"

# These gems are not part of the main/minimum bundle.
# If we don't find them we should ignore and move on.
begin
  require "pry"
  require "sdoc"
  require "rdoc/task"
rescue LoadError; end

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

if defined?(RDoc)
  RDoc::Task.new do |t|
    t.rdoc_dir = "doc"
    t.rdoc_files.include("README.md", "lib/**/*.rb")
    t.options << "--format=sdoc"
    t.template = "rails"
  end
end

task :console do
  Pry.start
end
