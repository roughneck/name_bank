# frozen_string_literal: true

require "yaml"

module NameBank
  # Lazy, memoized loader of per-country name pools stored as YAML in data_dir.
  class Repository
    def initialize(data_dir:)
      @data_dir = data_dir
      @countries_cache = {}
      @variants_cache = {}
    end

    def firstnames(country:, gender:, variant: nil)
      load(country, variant).fetch(gender_key(gender))
    end

    def lastnames(country:, variant: nil)
      load(country, variant).fetch("lastnames")
    end

    def countries
      @countries ||= yml_basenames(File.join(@data_dir, "countries"))
    end

    def variants(country:)
      yml_basenames(File.join(@data_dir, "variants", country))
    end

    private

    def gender_key(gender)
      case gender
      when :male then "firstnames_male"
      when :female then "firstnames_female"
      else raise ArgumentError, "gender must be :male or :female, got #{gender.inspect}"
      end
    end

    def load(country, variant)
      variant ? load_variant(country, variant) : load_country(country)
    end

    def load_country(country)
      @countries_cache[country] ||= begin
        path = File.join(@data_dir, "countries", "#{country}.yml")
        raise UnknownCountry, country unless File.exist?(path)

        YAML.safe_load_file(path)
      end
    end

    def load_variant(country, variant)
      @variants_cache[[country, variant]] ||= begin
        path = File.join(@data_dir, "variants", country, "#{variant}.yml")
        raise UnknownVariant, "#{country}/#{variant}" unless File.exist?(path)

        YAML.safe_load_file(path)
      end
    end

    def yml_basenames(dir)
      return [] unless Dir.exist?(dir)

      Dir.children(dir).select { |f| f.end_with?(".yml") }
         .map { |f| File.basename(f, ".yml") }.sort
    end
  end
end
