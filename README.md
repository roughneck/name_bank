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

## Scripts

Names come in Latin (default) and, for countries with a non-Latin writing
system, their native script. Pass `script:`:

```ruby
NameBank.first_name(country: "RU", gender: :male, rng: rng)                  # => "Dmitry"
NameBank.first_name(country: "RU", gender: :male, rng: rng, script: :native) # => "Алексей"

NameBank.scripts(country: "RU")   # => [:latin, :native]
NameBank.scripts(country: "DE")   # => [:latin]   (Latin is Germany's script)
```

`:latin` and `:native` sample from independent pools. For Latin-script countries
`:native` returns the same (Latin) pool. Requesting a script with no names
raises `NameBank::UnknownScript`.

## Variants

Some countries offer an alternate cultural name pool layered on the default.
Pass `variant:`:

```ruby
NameBank.first_name(country: "US", gender: :male, rng: rng, variant: "african_american")
# => "DeShawn"

NameBank.variants(country: "US")   # => ["african_american"]
NameBank.variants(country: "DE")   # => []
```

## Supported countries

106 countries: Afghanistan, Albania, Algeria, Angola, Argentina, Austria,
Azerbaijan, Bahrain, Bangladesh, Belgium, Bolivia, Botswana, Brazil, Brunei,
Bulgaria, Burkina Faso, Burundi, Cambodia, Cameroon, Canada, Chile, China,
Colombia, Costa Rica, Croatia, Cyprus, Czechia, Denmark, Djibouti, Ecuador,
Egypt, El Salvador, Estonia, Ethiopia, Fiji, Finland, France, Georgia, Germany,
Ghana, Greece, Guatemala, Haiti, Honduras, Hong Kong, Hungary, Iceland, India,
Indonesia, Iran, Iraq, Ireland, Israel, Italy, Jamaica, Japan, Jordan,
Kazakhstan, Kuwait, Lebanon, Libya, Lithuania, Luxembourg, Macau, Malaysia,
Maldives, Malta, Mauritius, Mexico, Moldova, Morocco, Namibia, Netherlands,
Nigeria, Norway, Oman, Palestine, Panama, Peru, Philippines, Poland, Portugal,
Puerto Rico, Qatar, Russia, Saudi Arabia, Serbia, Singapore, Slovenia, South
Africa, South Korea, Spain, Sudan, Sweden, Switzerland, Syria, Taiwan, Tunisia,
Turkey, Turkmenistan, Ukraine, United Arab Emirates, United Kingdom, United
States, Uruguay, Yemen.

## Pool sizes

Each country provides up to 1500 given names per gender and up to 1500
surnames; 89 of the 106 countries reach that cap on all three Latin pools, and
the rest are as large as the source data allows. 35 countries also carry a
native-script pool. Full per-country counts (Latin and native):
[docs/name-counts.md](docs/name-counts.md).

## License

Apache-2.0.
