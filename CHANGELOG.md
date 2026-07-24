# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.5] - 2026-07-24

Metadata and documentation only — no API, data or behaviour change.

### Added
- `spec.metadata` in the gemspec: source, changelog, documentation and bug
  tracker links, and `rubygems_mfa_required`.
- README: "Where it fits" (factory_bot, `db/seeds.rb`, RSpec examples) and
  "Relation to Faker and FFaker" with a comparison table.

### Changed
- Gem summary and description rewritten so the gem is findable for fake, test
  and seed name data, and states how it relates to Faker and FFaker.
- README intro says 106 countries (was "105+").

## [0.1.4] - 2026-07-24

### Added
- `script:` keyword on `first_name`, `last_name`, `full_name` (default `:latin`)
  selecting the Latin or native-script pool; `NameBank.scripts(country:)` lists
  available scripts. New error `NameBank::UnknownScript`.
- Native-script pools (Arabic, Cyrillic, Hangul, Han, Kana, Greek, Hebrew,
  Georgian, Khmer, Bengali) for the countries that use them.
- `docs/name-counts.md`: per-country pool sizes, linked from the README.

### Changed
- Re-baked all pools larger (N=6000) and split by script; foreign-script noise
  removed from Latin pools. Default (`:latin`) output for non-Latin countries is
  now Latin-only (previously mixed). Curated CN/UA pools unchanged.

## [0.1.3] - 2026-07-23

### Added
- README: "Supported countries" section listing all 106 countries by name,
  comma-separated.
- Tests: `last_name` with a `variant:` (public API and repository level), and a
  variant lookup on an unknown country raising `UnknownVariant`.

## [0.1.2] - 2026

### Fixed
- Corrected the GitHub homepage to the roughneck org.

## [0.1.1] - 2026

### Changed
- Neutral gem description; install/usage README.

## [0.1.0] - 2026

### Added
- Lazy, memoized per-country name repository.
- Deterministic uniform sampling API: `first_name`, `last_name`, `full_name`,
  `countries`, `variants`.
- Baked top given and family names for 105 countries from name-dataset.
- Curated Ukraine name pool for a dataset gap.
- Curated pinyin pool for China, replacing polluted dataset names.
- US `african_american` cultural variant.
- Apache-2.0 license and NOTICE.
