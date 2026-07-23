# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
