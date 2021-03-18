require "bundler/setup"
require "pry"
require "opt_struct"

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :expect }
  config.default_formatter = "doc" if config.files_to_run.one?
end
