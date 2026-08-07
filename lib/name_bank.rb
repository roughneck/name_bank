# frozen_string_literal: true

require_relative "name_bank/version"
require_relative "name_bank/errors"
require_relative "name_bank/pool_schema"
require_relative "name_bank/pool_store"

# Authentic, gender-matched given names and surnames for 106 countries,
# addressed by ISO alpha-2 country code. Sampling is uniform and deterministic
# from a caller-supplied RNG — no global locale or random state.
#
# The class-level methods delegate to a default instance over the shipped data
# dir; instantiate with another data_dir to read pools from elsewhere. Country
# and variant files are read lazily and memoized per instance.
#
# Every error raised here is a NameBank::Error; see the README for the list.
class NameBank
  DATA_DIR = File.expand_path("../data", __dir__)

  # Every class-level method forwards to the default instance, so the signatures
  # live once — on the instance methods below.
  class << self
    def default
      @default ||= new
    end

    def first_name(...) = default.first_name(...)
    def last_name(...) = default.last_name(...)
    def full_name(...) = default.full_name(...)
    def first_names(...) = default.first_names(...)
    def last_names(...) = default.last_names(...)
    def countries(...) = default.countries(...)
    def variants(...) = default.variants(...)
    def scripts(...) = default.scripts(...)
  end

  def initialize(data_dir: DATA_DIR)
    @store = PoolStore.new(data_dir)
  end

  def first_name(country:, gender:, rng:, variant: nil, script: :latin)
    first_names(country: country, gender: gender, variant: variant, script: script).sample(random: rng)
  end

  def last_name(country:, rng:, variant: nil, script: :latin)
    last_names(country: country, variant: variant, script: script).sample(random: rng)
  end

  def full_name(country:, gender:, rng:, variant: nil, script: :latin)
    {
      firstname: first_name(country: country, gender: gender, rng: rng, variant: variant, script: script),
      lastname: last_name(country: country, rng: rng, variant: variant, script: script)
    }
  end

  # The whole frequency-ordered pool, frozen. The name strings stay mutable.
  def first_names(country:, gender:, variant: nil, script: :latin)
    pool(country, variant, PoolSchema.gender_key(gender), script)
  end

  def last_names(country:, variant: nil, script: :latin)
    pool(country, variant, PoolSchema::SURNAMES, script)
  end

  def countries
    @store.countries
  end

  def variants(country:)
    @store.variants(country)
  end

  # The script forms this country offers, not writing systems — see CONTEXT.md.
  def scripts(country:)
    data = @store.pools(country, nil)
    PoolSchema::KEYS.any? { |k| data[PoolSchema.native_key(k)]&.any? } ? %i[latin native] : %i[latin]
  end

  private

  def pool(country, variant, key, script)
    names = names_for_script(@store.pools(country, variant), key, script)
    raise EmptyPool, "#{country}/#{script}" if names.empty?

    names.freeze
  end

  def names_for_script(data, key, script)
    case script
    when :latin then data.fetch(key)
    when :native
      native = data[PoolSchema.native_key(key)]
      native && !native.empty? ? native : data.fetch(key)
    else
      raise UnknownScript, "script must be :latin or :native, got #{script.inspect}"
    end
  end
end
