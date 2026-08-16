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
    def full_names(...) = default.full_names(...)
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

  # Distinct given/family pairs, for seeding many rows at once. No pair is drawn
  # twice; single names do recur, which is what a population looks like. The
  # guarantee holds within one call — two calls know nothing of each other.
  # Asking for more pairs than the two pools can form raises PoolExhausted.
  def full_names(country:, gender:, rng:, count:, variant: nil, script: :latin)
    firsts = first_names(country: country, gender: gender, variant: variant, script: script)
    lasts = last_names(country: country, variant: variant, script: script)
    available = firsts.size * lasts.size
    raise PoolExhausted, "#{country}: #{count} pairs requested, #{available} available" if count > available

    distinct_indices(available, count, rng).map do |index|
      { firstname: firsts[index / lasts.size], lastname: lasts[index % lasts.size] }
    end
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
  # With a variant, the forms that variant offers, which may differ.
  def scripts(country:, variant: nil)
    data = @store.pools(country, variant)
    PoolSchema::KEYS.any? { |k| data[PoolSchema.native_key(k)]&.any? } ? %i[latin native] : %i[latin]
  end

  private

  # Partial Fisher-Yates over the space of pair indices, with the swaps kept in
  # a Hash so that the untouched majority of a two-million-pair space is never
  # built. Drawing every pair a country has takes count steps; drawing at random
  # until enough distinct pairs turn up would stall on the last few.
  def distinct_indices(available, count, rng)
    swapped = {}
    Array.new(count) do |drawn|
      index = rng.rand(drawn...available)
      picked = swapped.fetch(index, index)
      swapped[index] = swapped.fetch(drawn, drawn)
      picked
    end
  end

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
