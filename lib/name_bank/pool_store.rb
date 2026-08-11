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
  #
  # Country and variant names are resolved against the directory listing rather
  # than handed to File.exist?, so the result does not depend on whether the
  # filesystem happens to be case-sensitive.
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
      code = resolve(country, variant_countries)
      return [] if code.nil?

      @variant_names[code] ||= yml_basenames(File.join(@data_dir, "variants", code))
    end

    private

    # An exact match wins; otherwise a unique case-insensitive one; otherwise
    # nil, because guessing between DE and de would be worse than refusing.
    def resolve(name, candidates)
      return name if candidates.include?(name)

      hits = matches(name, candidates)
      hits.size == 1 ? hits.first : nil
    end

    def matches(name, candidates)
      candidates.select { |candidate| candidate.casecmp?(name) }
    end

    # What to put in the error: the name alone when nothing matched, or the
    # rival spellings when several did.
    def unresolved(name, candidates)
      hits = matches(name, candidates)
      hits.empty? ? name : "#{name} matches #{hits.join(", ")}"
    end

    def country_pools(country)
      code = resolve(country, countries)
      raise UnknownCountry, unresolved(country, countries) if code.nil?

      @country_pools[code] ||= read(File.join(@data_dir, "countries", "#{code}.yml"))
    end

    def variant_pools(country, variant)
      code = resolve(country, variant_countries)
      raise UnknownVariant, "#{country}/#{variant}" if code.nil?

      name = resolve(variant, variants(code))
      raise UnknownVariant, "#{country}/#{unresolved(variant, variants(code))}" if name.nil?

      @variant_pools[[code, name]] ||= read(File.join(@data_dir, "variants", code, "#{name}.yml"))
    end

    def read(path)
      data = YAML.safe_load_file(path)
      PoolSchema::KEYS.each do |key|
        raise MalformedPool, "#{path}: #{key} must be a list of names" unless data[key].is_a?(Array)
      end
      data
    end

    def variant_countries
      @variant_countries ||= subdirectories(File.join(@data_dir, "variants"))
    end

    def subdirectories(dir)
      return [] unless Dir.exist?(dir)

      Dir.children(dir).select { |child| File.directory?(File.join(dir, child)) }.sort
    end

    def yml_basenames(dir)
      return [] unless Dir.exist?(dir)

      Dir.children(dir).select { |f| f.end_with?(".yml") }
        .map { |f| File.basename(f, ".yml") }.sort
    end
  end

  private_constant :PoolStore
end
