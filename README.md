# name_bank

Authentic, gender-matched given and family names for 106 countries. Deep
pools (up to 1500 per country/gender), uniform sampling, deterministic, no
runtime dependencies.

Realistic fake name data for database seeds, factories, fixtures and demo
environments — a companion to [Faker](https://github.com/faker-ruby/faker) and
[FFaker](https://github.com/ffaker/ffaker) for the name part.

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

## Where it fits

A factory_bot factory:

```ruby
FactoryBot.define do
  factory :user do
    transient do
      country { "DE" }
      person_gender { :female }
      rng { Random.new }
      person { NameBank.full_name(country: country, gender: person_gender, rng: rng) }
    end

    first_name { person[:firstname] }
    last_name  { person[:lastname] }
  end
end
```

Database seeds with a fixed seed, so every run produces the same data:

```ruby
# db/seeds.rb
rng = Random.new(20_260_724)

%w[DE FR IT ES PL].each do |country|
  100.times do
    person = NameBank.full_name(country: country, gender: [:male, :female].sample(random: rng), rng: rng)
    User.create!(first_name: person[:firstname], last_name: person[:lastname], country: country)
  end
end
```

An RSpec example — the seeded RNG makes the case reproducible:

```ruby
it "fits a long Cyrillic name into the invoice header" do
  rng = Random.new(1234)
  customer = NameBank.full_name(country: "RU", gender: :female, rng: rng, script: :native)

  header = InvoicePdf.new(customer).header

  expect(header).to include(customer[:lastname])
end
```

## Relation to Faker and FFaker

Faker and FFaker are full fake-data suites — addresses, companies, lorem ipsum,
and much more. name_bank does one thing: people names. Use it alongside them,
not instead of them.

|                      | Faker                                                        | FFaker                                     | name_bank                                                   |
| -------------------- | ------------------------------------------------------------ | ------------------------------------------ | ----------------------------------------------------------- |
| Scope                | full fake-data suite                                          | full fake-data suite                        | people names only                                            |
| Names addressed by   | 58 language/region locales (`de`, `de-AT`, `en-US`)           | 30 language modules (`FFaker::NameDE`)      | 106 ISO country codes (`DE`, `RU`, `JP`)                     |
| Gendered given names | in about 24 of those locales                                  | in 17 of the 30 name modules                | in every country                                             |
| Pool depth           | uneven: `en` 1219 m / 4271 f, `de` 574 / 585, `ru` 52 / 56, `ko` 21 | varies per module                     | up to 1500 per country, gender and script; 89 of 106 at the cap |
| Native script        | one form per locale                                           | one form per module                         | Latin and native as separate pools, 35 countries             |
| Randomness           | global `Faker::Config.random`                                 | global `FFaker::Random.seed`                | `rng:` passed in per call, no global state                   |

Counts measured against `faker` and `ffaker` `main` on 2026-07-24.

Moving a name call over:

```ruby
Faker::Name.first_name
FFaker::NameDE.first_name
# both: gender-agnostic, locale/module picked from global state

NameBank.first_name(country: "DE", gender: :female, rng: rng)
# country and gender explicit, RNG explicit
```

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
