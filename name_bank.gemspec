# frozen_string_literal: true

require_relative "lib/name_bank/version"

Gem::Specification.new do |spec|
  spec.name        = "name_bank"
  spec.version     = NameBank::VERSION
  spec.authors     = ["Patrick Bartels"]
  spec.summary     = "Authentic, gender-matched given names and surnames for 106 countries — " \
                     "fake name data for seeds, factories and tests."
  spec.description = "NameBank generates authentic, gender-matched given names and surnames " \
                     "for 106 countries, addressed by ISO alpha-2 country code, including " \
                     "native-script pools (Cyrillic, Arabic, Han, Hangul, Kana, Greek, Hebrew " \
                     "and more) for 35 of them. Pools hold up to 1500 names per country, gender " \
                     "and script. Use it for realistic fake name data in database seeds, " \
                     "factory_bot factories, RSpec fixtures, demo and staging data. It " \
                     "complements the general-purpose fake data gems Faker and FFaker rather " \
                     "than replacing them: keep those for addresses, companies and lorem ipsum, " \
                     "and use name_bank where you need per-country, gender-matched people names " \
                     "with deep pools. Sampling is uniform and deterministic from a " \
                     "caller-supplied RNG — no global locale or random state. No runtime " \
                     "dependencies."
  spec.homepage    = "https://github.com/roughneck/name_bank"
  spec.license     = "Apache-2.0"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "source_code_uri" => "https://github.com/roughneck/name_bank",
    "changelog_uri" => "https://github.com/roughneck/name_bank/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://rubydoc.info/gems/name_bank",
    "bug_tracker_uri" => "https://github.com/roughneck/name_bank/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*.rb", "data/**/*.yml", "LICENSE", "NOTICE", "README.md", "CHANGELOG.md", "docs/name-counts.md"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rake", "~> 13.0"
end
