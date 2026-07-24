# frozen_string_literal: true

require "yaml"
require_relative "script_classifier"
require_relative "../lib/name_bank/pool_schema"

# Stage 2 of the data pipeline: split each re-baked country's mixed-script pool
# into a Latin base pool and (for allowlisted countries) a native-script pool,
# capping each at LIMIT and dropping foreign-script noise. Curated countries
# (CN, UA) are left untouched. Run after tools/bake.py.
#
# Idempotent: it reads both the base and any existing *_native keys back into
# the candidate pool before splitting, so re-running on already-split data
# reproduces the same output rather than dropping the native pools.
module SplitScripts
  Schema = NameBank::PoolSchema
  LIMIT = 1500
  CURATED = %w[CN UA].freeze

  # country -> accepted native scripts
  NATIVE = {
    "YE" => [:arabic], "SD" => [:arabic], "LY" => [:arabic], "IQ" => [:arabic],
    "JO" => [:arabic], "SY" => [:arabic], "AF" => [:arabic], "EG" => [:arabic],
    "LB" => [:arabic], "DZ" => [:arabic], "OM" => [:arabic], "TN" => [:arabic],
    "SA" => [:arabic], "BH" => [:arabic], "AE" => [:arabic], "DJ" => [:arabic],
    "IR" => [:arabic], "PS" => [:arabic],
    "RU" => [:cyrillic], "KZ" => [:cyrillic], "BG" => [:cyrillic],
    "TM" => [:cyrillic], "RS" => [:cyrillic], "AZ" => [:cyrillic],
    "KR" => [:hangul],
    "TW" => [:han], "HK" => [:han], "MO" => [:han],
    "JP" => %i[han kana],
    "GR" => [:greek], "CY" => [:greek],
    "IL" => [:hebrew], "GE" => [:georgian], "KH" => [:khmer], "BD" => [:bengali]
  }.freeze

  module_function

  def split_country(country, data)
    out = { "source" => data["source"] || "dataset" }
    latin = pools(data) { |name| ScriptClassifier.script_of(name) == :latin }
    Schema::KEYS.each { |key| out[key] = latin[key] }
    add_native_pools(out, data, NATIVE[country])
    out
  end

  # Candidate names per pool key, filtered by the given script predicate and
  # capped at LIMIT. Any already-split *_native names are read back in, so
  # re-running on split data reproduces it instead of dropping the natives.
  def pools(data, &script_filter)
    Schema::KEYS.to_h do |key|
      names = (data[key] || []) + (data[Schema.native_key(key)] || [])
      [key, names.select(&script_filter).first(LIMIT)]
    end
  end

  def add_native_pools(out, data, native_scripts)
    return unless native_scripts

    native = pools(data) { |name| native_scripts.include?(ScriptClassifier.script_of(name)) }
    return if native.each_value.all?(&:empty?)

    Schema::KEYS.each { |key| out[Schema.native_key(key)] = native[key] }
  end

  def run(countries_dir)
    Dir.children(countries_dir).select { |f| f.end_with?(".yml") }.sort.each do |file|
      country = File.basename(file, ".yml")
      next if CURATED.include?(country)

      split_file(File.join(countries_dir, file), country)
    end
  end

  def split_file(path, country)
    result = split_country(country, YAML.safe_load_file(path))
    File.write(path, YAML.dump(result))
    native = Schema::KEYS.sum { |k| (result[Schema.native_key(k)] || []).size }
    puts "#{country}: latin=#{data_size(result)} native=#{native}"
  end

  # Variants carry no native pools; strip any non-Latin noise, keep Latin only.
  def run_variants(variants_dir)
    Dir.glob(File.join(variants_dir, "*", "*.yml")).each do |path|
      data = YAML.safe_load_file(path)
      out = { "source" => data["source"] || "dataset" }
      Schema::KEYS.each { |key| out[key] = latin_only(data[key]) }
      File.write(path, YAML.dump(out))
      puts "variant #{path}"
    end
  end

  def latin_only(names)
    (names || []).select { |name| ScriptClassifier.script_of(name) == :latin }.first(LIMIT)
  end

  def data_size(out)
    Schema::KEYS.sum { |k| (out[k] || []).size }
  end
end

SplitScripts.run(ARGV[0] || "data/countries") if $PROGRAM_NAME == __FILE__
