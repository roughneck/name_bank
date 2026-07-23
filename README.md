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

## License

Apache-2.0.
