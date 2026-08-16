# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-08-16

Many names in one call. Nothing that worked before changes: sampling from the
existing methods is byte-identical to 0.3.0 over 2830 samples across every
country, script and variant, and the name data is untouched.

### Added
- `full_names(country:, gender:, rng:, count:)` draws that many distinct
  given/family pairs in one call — the shape a database seed needs. No pair
  repeats; single names do, because only the pair is unique. The guarantee
  holds within one call, so no state is kept between calls and sampling stays
  a function of the caller's RNG. `count:` is required, and asking for more
  pairs than the two pools can form raises the new `NameBank::PoolExhausted`
  rather than silently returning fewer.

### Fixed
- README: the first usage example showed a name pair that the seed above it
  never produces. Every `# =>` in the README is now the value the code actually
  returns, checked against the shipped pools. The sampling examples under
  *Scripts* and *Variants* name their seed too, so all of them can be
  reproduced rather than taken on trust. No code or data changed.

## [0.3.0] - 2026-08-11

Lookup, documentation and one platform bug. Sampling behaviour and the name
data are unchanged — verified byte-identical over 1415 samples against 0.2.0.
Nothing that worked before stops working; on Linux, one thing that failed now
works.

### Added
- `scripts` takes an optional `variant:`. A variant can offer different script
  forms from the country it is layered on; previously `scripts(country:)` only
  ever reported the country's own.

### Fixed
- Country and variant names now resolve against the directory listing instead
  of being handed to `File.exist?`, so lookup no longer inherits the
  filesystem's case-sensitivity. `country: "de"` found `DE.yml` on macOS and
  raised `UnknownCountry` on Linux; it now finds it on both. An exact match
  still wins, and names that differ only in case are reported as ambiguous
  rather than guessed at.
- README: a pool with no names was documented as raising
  `NameBank::UnknownScript`. It has raised `NameBank::EmptyPool` since 0.2.0.

### Documented
- The pool file format: the directory layout `NameBank.new(data_dir:)` expects,
  which keys a file must carry, how `_native` pools are named, and which
  failures a malformed file produces. Variant files may carry `_native` pools —
  supported by the reader since 0.1.4, now stated and covered by a spec.
- `NameBank::PoolSchema` is now documented in the README and is supported
  public API: `KEYS`, `GIVEN_MALE`, `GIVEN_FEMALE`, `SURNAMES`, `native_key`
  and `gender_key`. It shipped before but was described nowhere. Callers
  building pool files for `NameBank.new(data_dir:)` should address the YAML
  keys through it. The key names are covered by semantic versioning from here
  on: renaming one is a breaking change.

## [0.2.0] - 2026-08-08

An interface release. Sampling behaviour and the name data are unchanged — the
same `country:`, `gender:`, `rng:`, `variant:` and `script:` calls return the
same names as 0.1.6. What changed is what else the interface offers, and how
failures are named. Three breaking changes are listed below.

### Added
- `NameBank.first_names` and `NameBank.last_names` return a country's whole
  frequency-ordered pool as a frozen array. They take the same `country:`,
  `gender:`, `variant:` and `script:` options as the samplers.
- `NameBank` is now a class and can be instantiated: `NameBank.new(data_dir:)`
  reads pools from a directory of your own. The class-level methods delegate to
  a default instance over the shipped data.

### Removed
- **Breaking:** `NameBank.repository` and the `NameBank::Repository` class. The
  accessor was never documented; everything it offered is on `NameBank` itself,
  with `firstnames`/`lastnames` renamed to `first_names`/`last_names`.

- `NameBank::MalformedPool`, raised when a pool file is missing a schema key or
  holds something other than a list. Files are validated once when read.
- `NameBank::UnknownGender` and `NameBank::EmptyPool`, so every failure the gem
  can produce has a name. The README now lists all six.

### Changed
- `variants(country:)` is memoized like `countries`, so repeated calls no longer
  hit the filesystem.
- **Breaking:** `NameBank::Error` is now a module mixed into every error rather
  than their shared superclass. `rescue NameBank::Error` works as before and now
  covers every failure, including the two argument errors that previously
  escaped it; each error also keeps its natural superclass, so
  `rescue ArgumentError` still catches a bad `gender:` or `script:`. Raising or
  instantiating `NameBank::Error` itself is no longer possible.
- **Breaking:** `NameBank::UnknownScript` now means what its name says — a
  `script:` that is neither `:latin` nor `:native`, previously a bare
  `ArgumentError`. The empty-pool case it used to signal is now
  `NameBank::EmptyPool`.

## [0.1.6] - 2026-07-24

Tooling and internals only — no API, data or behaviour change.

### Added
- RuboCop (with rubocop-rspec, rubocop-rake, rubocop-performance) and
  bundler-audit as development dependencies. The default Rake task now runs
  `spec`, `rubocop` and `bundle:audit:check`.
- `rake release_check`: the same checks, but refreshing the advisory database
  first. Run before releasing.

### Changed
- Development dependencies moved from the gemspec to the `:development` group
  in the Gemfile; the gemspec no longer declares any.
- Internals split for readability: `Repository#names_for_script` extracted from
  `#pool`, and `SplitScripts.split_country` split into `pools`,
  `add_native_pools`, `split_file` and `latin_only`.
- Specs reorganised — class specs under `spec/name_bank/`, one assertion per
  example.

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
