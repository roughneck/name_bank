# frozen_string_literal: true

require_relative "lib/name_bank/version"

Gem::Specification.new do |spec|
  spec.name        = "name_bank"
  spec.version     = NameBank::VERSION
  spec.authors     = ["Patrick Bartels"]
  spec.summary     = "Authentic, gender-matched given and family names for 105+ countries."
  spec.description = "A fast, dependency-free generator of authentic, gender-matched " \
                     "given names and surnames for 105+ countries, plus hand-curated " \
                     "pools and cultural variants. Uniform, deterministic sampling from " \
                     "a caller-supplied RNG."
  spec.homepage    = "https://github.com/roughneck/name_bank"
  spec.license     = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir["lib/**/*.rb", "data/**/*.yml", "LICENSE", "NOTICE", "README.md", "CHANGELOG.md", "docs/name-counts.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rake", "~> 13.0"
end
