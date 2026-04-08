require "bundler/setup"
require "opt_struct"

# Part of the development bundle. Ignore if we don't find.
begin
  require "pry"
rescue LoadError; end

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.default_formatter = "doc" if config.files_to_run.one?
end
