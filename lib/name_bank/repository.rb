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

    def firstnames(country:, gender:, variant: nil, script: :latin)
      pool(load(country, variant), PoolSchema.gender_key(gender), script, country)
    end

    def lastnames(country:, variant: nil, script: :latin)
      pool(load(country, variant), "lastnames", script, country)
    end

    def scripts(country:)
      data = load(country, nil)
      PoolSchema::KEYS.any? { |k| data[PoolSchema.native_key(k)]&.any? } ? %i[latin native] : %i[latin]
    end

    def countries
      @countries ||= yml_basenames(File.join(@data_dir, "countries"))
    end

    def variants(country:)
      yml_basenames(File.join(@data_dir, "variants", country))
    end

    private

    def pool(data, key, script, country)
      names = names_for_script(data, key, script)
      raise UnknownScript, "#{country}/#{script}" if names.nil? || names.empty?

      names
    end

    def names_for_script(data, key, script)
      case script
      when :latin then data.fetch(key)
      when :native
        native = data[PoolSchema.native_key(key)]
        native && !native.empty? ? native : data.fetch(key)
      else
        raise ArgumentError, "script must be :latin or :native, got #{script.inspect}"
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
