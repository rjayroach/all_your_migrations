$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "all_your_migrations/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "all_your_migrations"
  s.version     = AllYourMigrations::VERSION
  s.authors       = ["Robert Roach"]
  s.email         = ["rjayroach@gmail.com"]
  s.summary       = %q{Tools to support data migrations from legacy databases}
  #s.description   = %q{TODO: Write a longer description. Optional.}
  s.homepage      = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.1.6"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "pry-rails"
end
