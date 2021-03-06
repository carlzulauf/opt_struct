lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opt_struct/version'

Gem::Specification.new do |spec|
  spec.name          = "opt_struct"
  spec.version       = OptStruct::VERSION
  spec.authors       = ["Carl Zulauf"]
  spec.email         = ["carl@linkleaf.com"]

  spec.summary       = %q{The Option Struct}
  spec.description   = %q{Struct with support for keyword params and mixin support}
  spec.homepage      = "https://github.com/carlzulauf/opt_struct"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n").grep(/^lib/)
  spec.files        += %w(README.md opt_struct.gemspec)
  spec.require_paths = ["lib"]
end
