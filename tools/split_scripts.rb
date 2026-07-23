# frozen_string_literal: true

# Stage 2 of the data pipeline: split each re-baked country's mixed-script pool
# into a Latin base pool and (for allowlisted countries) a native-script pool,
# capping each at LIMIT and dropping foreign-script noise. Curated countries
# (CN, UA) are left untouched. Run after tools/bake.py.
#
# Idempotent: it reads both the base and any existing *_native keys back into
# the candidate pool before splitting, so re-running on already-split data
# reproduces the same output rather than dropping the native pools.
require "yaml"
require_relative "script_classifier"

module SplitScripts
  KEYS = %w[firstnames_male firstnames_female lastnames].freeze
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
    "JP" => [:han, :kana],
    "GR" => [:greek], "CY" => [:greek],
    "IL" => [:hebrew], "GE" => [:georgian], "KH" => [:khmer], "BD" => [:bengali]
  }.freeze

  module_function

  def split_country(country, data)
    native_scripts = NATIVE[country]
    out = { "source" => data["source"] || "dataset" }

    latin = {}
    native = {}
    KEYS.each do |key|
      # Include any already-split *_native names so re-running is idempotent
      # (a second pass would otherwise see a Latin-only base and drop natives).
      names = (data[key] || []) + (data["#{key}_native"] || [])
      latin[key] = names.select { |n| ScriptClassifier.script_of(n) == :latin }.first(LIMIT)
      native[key] = names.select { |n| native_scripts&.include?(ScriptClassifier.script_of(n)) }.first(LIMIT) if native_scripts
    end

    KEYS.each { |key| out[key] = latin[key] }
    if native_scripts && KEYS.any? { |k| !native[k].empty? }
      KEYS.each { |key| out["#{key}_native"] = native[key] }
    end
    out
  end

  def run(countries_dir)
    Dir.children(countries_dir).select { |f| f.end_with?(".yml") }.sort.each do |file|
      country = File.basename(file, ".yml")
      next if CURATED.include?(country)

      path = File.join(countries_dir, file)
      result = split_country(country, YAML.safe_load_file(path))
      File.write(path, YAML.dump(result))
      native = KEYS.sum { |k| (result["#{k}_native"] || []).size }
      puts "#{country}: latin=#{data_size(result)} native=#{native}"
    end
  end

  # Variants carry no native pools; strip any non-Latin noise, keep Latin only.
  def run_variants(variants_dir)
    Dir.glob(File.join(variants_dir, "*", "*.yml")).sort.each do |path|
      data = YAML.safe_load_file(path)
      out = { "source" => data["source"] || "dataset" }
      KEYS.each { |key| out[key] = (data[key] || []).select { |n| ScriptClassifier.script_of(n) == :latin }.first(LIMIT) }
      File.write(path, YAML.dump(out))
      puts "variant #{path}"
    end
  end

  def data_size(out)
    KEYS.sum { |k| (out[k] || []).size }
  end
end

SplitScripts.run(ARGV[0] || "data/countries") if $PROGRAM_NAME == __FILE__
