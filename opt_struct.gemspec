Gem::Specification.new do |spec|
  spec.name          = "opt_struct"
  spec.version       = "0.7.0"
  spec.authors       = ["Carl Zulauf"]
  spec.email         = ["carl@linkleaf.com"]

  spec.summary       = %q{The Option Struct}
  spec.description   = %q{Struct with support for keyword params and mixin support}
  spec.homepage      = "https://github.com/carlzulauf/opt_struct"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n").grep(/^lib/)
  spec.files        += %w(README.md opt_struct.gemspec)
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
