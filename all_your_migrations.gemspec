# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'all_your_migrations/version'

Gem::Specification.new do |spec|
  spec.name          = "all_your_migrations"
  spec.version       = AllYourMigrations::VERSION
  spec.authors       = ["Robert Roach"]
  spec.email         = ["rjayroach@gmail.com"]
  spec.summary       = %q{Tools to support data migrations from legacy databases}
  #spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "sqlite3"
end
