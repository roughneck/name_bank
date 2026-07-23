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

  RANGES = {
    arabic: [0x0600..0x06FF, 0x0750..0x077F],
    han: [0x4E00..0x9FFF, 0x3400..0x4DBF],
    hangul: [0xAC00..0xD7AF],
    kana: [0x3040..0x30FF],
    cyrillic: [0x0400..0x04FF],
    hebrew: [0x0590..0x05FF],
    greek: [0x0370..0x03FF],
    georgian: [0x10A0..0x10FF],
    khmer: [0x1780..0x17FF],
    bengali: [0x0980..0x09FF],
    devanagari: [0x0900..0x097F],
    thai: [0x0E00..0x0E7F]
  }.freeze

  module_function

  def script_of(name)
    name.to_s.each_char do |ch|
      cp = ch.ord
      RANGES.each { |script, ranges| return script if ranges.any? { |r| r.cover?(cp) } }
    end
    :latin
  end

  def split_country(country, data)
    native_scripts = NATIVE[country]
    out = { "source" => data["source"] || "dataset" }

    latin = {}
    native = {}
    KEYS.each do |key|
      # Include any already-split *_native names so re-running is idempotent
      # (a second pass would otherwise see a Latin-only base and drop natives).
      names = (data[key] || []) + (data["#{key}_native"] || [])
      latin[key] = names.select { |n| script_of(n) == :latin }.first(LIMIT)
      native[key] = names.select { |n| native_scripts&.include?(script_of(n)) }.first(LIMIT) if native_scripts
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
      KEYS.each { |key| out[key] = (data[key] || []).select { |n| script_of(n) == :latin }.first(LIMIT) }
      File.write(path, YAML.dump(out))
      puts "variant #{path}"
    end
  end

  def data_size(out)
    KEYS.sum { |k| (out[k] || []).size }
  end
end

SplitScripts.run(ARGV[0] || "data/countries") if $PROGRAM_NAME == __FILE__
