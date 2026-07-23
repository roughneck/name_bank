# name_bank

Authentic, gender-matched given and family names for 105+ countries. Deep
pools (up to 1500 per country/gender), uniform sampling, deterministic, no
runtime dependencies.

## Installation

Add to your Gemfile:

```ruby
gem "name_bank"
```

Then run `bundle install`. Or install directly:

```bash
gem install name_bank
```

## Usage

```ruby
require "name_bank"

rng = Random.new(1234)

# A full name (given + family) for a country and gender:
NameBank.full_name(country: "DE", gender: :female, rng: rng)
# => { firstname: "Sabine", lastname: "Müller" }

# Just a given name or a surname:
NameBank.first_name(country: "IT", gender: :male, rng: rng)   # => "Giuseppe"
NameBank.last_name(country: "JP", rng: rng)                   # => "Tanaka"

# List available countries (ISO alpha-2 codes):
NameBank.countries
# => ["AE", "AF", "AL", ..., "ZA"]
```

Sampling is uniform over each pool and fully deterministic for a given
`rng` — the same seed always yields the same name. `gender:` is `:male`
or `:female`.

## Variants

Some countries offer an alternate cultural name pool layered on the default.
Pass `variant:`:

```ruby
NameBank.first_name(country: "US", gender: :male, rng: rng, variant: "african_american")
# => "DeShawn"

NameBank.variants(country: "US")   # => ["african_american"]
NameBank.variants(country: "DE")   # => []
```

## License

Apache-2.0.
