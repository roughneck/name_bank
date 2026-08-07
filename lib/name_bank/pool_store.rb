# frozen_string_literal: true

require "yaml"

require_relative "errors"
require_relative "pool_schema"

# Declared as a class, not a module: NameBank itself is one (see lib/name_bank.rb).
class NameBank
  # Everything that touches the filesystem: reading pool files, checking their
  # shape against PoolSchema, memoizing them, and listing what a data dir holds.
  # NameBank itself never opens a file. Files are read once per instance, and
  # validated once when read rather than on every pool access.
  class PoolStore
    def initialize(data_dir)
      @data_dir = data_dir
      @country_pools = {}
      @variant_pools = {}
      @variant_names = {}
    end

    def pools(country, variant)
      variant ? variant_pools(country, variant) : country_pools(country)
    end

    def countries
      @countries ||= yml_basenames(File.join(@data_dir, "countries"))
    end

    def variants(country)
      @variant_names[country] ||= yml_basenames(File.join(@data_dir, "variants", country))
    end

    private

    def country_pools(country)
      @country_pools[country] ||= begin
        path = File.join(@data_dir, "countries", "#{country}.yml")
        raise UnknownCountry, country unless File.exist?(path)

        read(path)
      end
    end

    def variant_pools(country, variant)
      @variant_pools[[country, variant]] ||= begin
        path = File.join(@data_dir, "variants", country, "#{variant}.yml")
        raise UnknownVariant, "#{country}/#{variant}" unless File.exist?(path)

        read(path)
      end
    end

    def read(path)
      data = YAML.safe_load_file(path)
      PoolSchema::KEYS.each do |key|
        raise MalformedPool, "#{path}: #{key} must be a list of names" unless data[key].is_a?(Array)
      end
      data
    end

    def yml_basenames(dir)
      return [] unless Dir.exist?(dir)

      Dir.children(dir).select { |f| f.end_with?(".yml") }
        .map { |f| File.basename(f, ".yml") }.sort
    end
  end

  private_constant :PoolStore
end
