# frozen_string_literal: true

require_relative "name_bank/version"
require_relative "name_bank/repository"

module NameBank
  Error = Class.new(StandardError)
  UnknownCountry = Class.new(Error)
  UnknownVariant = Class.new(Error)

  DATA_DIR = File.expand_path("../data", __dir__)

  module_function

  def first_name(country:, gender:, rng:, variant: nil)
    repository.firstnames(country: country, gender: gender, variant: variant).sample(random: rng)
  end

  def last_name(country:, rng:, variant: nil)
    repository.lastnames(country: country, variant: variant).sample(random: rng)
  end

  def full_name(country:, gender:, rng:, variant: nil)
    {
      firstname: first_name(country: country, gender: gender, rng: rng, variant: variant),
      lastname: last_name(country: country, rng: rng, variant: variant)
    }
  end

  def countries
    repository.countries
  end

  def variants(country:)
    repository.variants(country: country)
  end

  def repository
    @repository ||= Repository.new(data_dir: DATA_DIR)
  end
end
