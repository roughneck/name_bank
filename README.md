# name_bank

Authentic, gender-matched given and family names for 105+ countries. Deep
pools (up to 1500 per country/gender), uniform sampling, deterministic, no
runtime deps.

## Install

```ruby
gem "name_bank"
```

## Usage

```ruby
require "name_bank"

rng = Random.new(1234)
NameBank.full_name(country: "DE", gender: :female, rng: rng)
# => { firstname: "...", lastname: "..." }

NameBank.first_name(country: "US", gender: :male, rng: rng, variant: "african_american")
NameBank.countries          # => ["AE", "AF", "AL", ... "ZA"]
NameBank.variants(country: "US")  # => ["african_american"]
```

Sampling is uniform over each pool and fully deterministic given the `rng`
you pass in — same seed, same name.

## Provenance

Country pools tagged `source: dataset` derive from
[name-dataset](https://github.com/philipperemy/name-dataset) (Apache-2.0) —
aggregate top-frequency names only.

Two countries are curated overrides, tagged `source: curated`, and are
hand-authored rather than dataset-derived:

- `UA` (Ukraine) — a gap in the dataset; no dataset pool existed to bake.
- `CN` (China) — the dataset's Chinese given-name pool was low quality, so
  it was replaced with a hand-curated pinyin pool.

All `variants/` (e.g. `US/african_american`) are likewise hand-authored.
See `NOTICE`.

CJK-origin names are romanized for Latin-script consistency across the
whole gem: Japanese names are dataset-sourced romaji (`JP`), and Chinese
names are curated pinyin (`CN`).

## Variants

Variants layer an alternate name pool onto a base country (e.g.
`US/african_american`) without replacing the country's default pool. Pass
`variant:` to `first_name`/`last_name`/`full_name`; list what's available
for a country with `NameBank.variants(country:)`.

## Regenerating dataset pools

`python tools/bake.py` (needs `names-dataset`, ~3.2 GB RAM) rewrites every
`data/countries/<CC>.yml` for a dataset country code as `source: dataset`.
This **overwrites `data/countries/CN.yml`**, silently discarding the curated
pinyin override (CN is a valid dataset country code), and does **not**
produce `data/countries/UA.yml` (Ukraine is a dataset gap). The curated
overrides — `UA.yml`, `CN.yml`, and everything under `data/variants/` —
are committed by hand and must be re-applied after any re-bake.

## License

Apache-2.0.
