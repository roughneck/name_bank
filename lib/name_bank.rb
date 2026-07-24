# frozen_string_literal: true

require_relative "name_bank/version"
require_relative "name_bank/pool_schema"
require_relative "name_bank/repository"

# Authentic, gender-matched given names and surnames for 106 countries,
# addressed by ISO alpha-2 country code. Sampling is uniform and deterministic
# from a caller-supplied RNG — no global locale or random state.
module NameBank
  class Error < StandardError; end
  class UnknownCountry < Error; end
  class UnknownVariant < Error; end
  class UnknownScript < Error; end

  DATA_DIR = File.expand_path("../data", __dir__)

  module_function

  def first_name(country:, gender:, rng:, variant: nil, script: :latin)
    repository.firstnames(country: country, gender: gender, variant: variant, script: script).sample(random: rng)
  end

  def last_name(country:, rng:, variant: nil, script: :latin)
    repository.lastnames(country: country, variant: variant, script: script).sample(random: rng)
  end

  def full_name(country:, gender:, rng:, variant: nil, script: :latin)
    {
      firstname: first_name(country: country, gender: gender, rng: rng, variant: variant, script: script),
      lastname: last_name(country: country, rng: rng, variant: variant, script: script)
    }
  end

  def countries
    repository.countries
  end

  def variants(country:)
    repository.variants(country: country)
  end

  def scripts(country:)
    repository.scripts(country: country)
  end

  def repository
    @repository ||= Repository.new(data_dir: DATA_DIR)
  end
end
