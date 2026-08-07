# frozen_string_literal: true

require "spec_helper"
require_relative "../tools/script_classifier"

# Exercises the committed data/ dir through the class-level methods, which
# delegate to the default instance. The fixture-backed instance specs live in
# name_bank_spec.rb.
RSpec.describe NameBank do
  it "ships a healthy number of countries" do
    expect(described_class.countries.size).to be >= 100
  end

  describe "every country pool" do
    let(:pools) do
      described_class.countries.flat_map do |cc|
        [described_class.first_names(country: cc, gender: :male),
         described_class.first_names(country: cc, gender: :female),
         described_class.last_names(country: cc)]
      end
    end

    it "is an array" do
      expect(pools).to all(be_a(Array))
    end

    it "holds between 1 and 1500 names" do
      expect(pools.map(&:size)).to all(be_between(1, 1500))
    end

    it "holds strings only" do
      expect(pools.flatten).to all(be_a(String))
    end
  end

  describe "sampling from real data" do
    it "is deterministic for a major country" do
      a = described_class.full_name(country: "DE", gender: :male, rng: Random.new(99))
      b = described_class.full_name(country: "DE", gender: :male, rng: Random.new(99))
      expect(a).to eq(b)
    end

    it "yields a non-empty firstname" do
      result = described_class.full_name(country: "DE", gender: :male, rng: Random.new(99))
      expect(result[:firstname]).to be_a(String).and(satisfy { !_1.empty? })
    end

    it "yields a lastname from the country pool" do
      name = described_class.last_name(country: "DE", rng: Random.new(99))
      expect(described_class.last_names(country: "DE")).to include(name)
    end
  end

  describe "curated Ukraine" do
    it "is among the countries" do
      expect(described_class.countries).to include("UA")
    end

    it "samples a male first name" do
      expect(described_class.first_name(country: "UA", gender: :male, rng: Random.new(1))).to be_a(String)
    end

    it "samples a female first name" do
      expect(described_class.first_name(country: "UA", gender: :female, rng: Random.new(1))).to be_a(String)
    end

    it "keeps the male and female pools disjoint" do
      female = described_class.first_names(country: "UA", gender: :female)
      expect(described_class.first_names(country: "UA", gender: :male)).not_to include(*female)
    end
  end

  describe "curated China" do
    let(:male) { described_class.first_names(country: "CN", gender: :male) }
    let(:female) { described_class.first_names(country: "CN", gender: :female) }

    it "holds pinyin male given names" do
      expect(male).to include("Wei")
    end

    it "holds pinyin female given names" do
      expect(female).to include("Mei")
    end

    # The broken dataset pool leaked Western given names; the curated pool must not.
    it "keeps Western given names out of the male pool" do
      expect(male).not_to include("Jason")
    end

    it "keeps Western given names out of the female pool" do
      expect(female).not_to include("Lily")
    end
  end

  describe "the US african_american variant" do
    let(:pool) { described_class.first_names(country: "US", gender: :male, variant: "african_american") }

    it "is exposed as a variant" do
      expect(described_class.variants(country: "US")).to include("african_american")
    end

    it "is the pool that sampling draws from" do
      name = described_class.first_name(country: "US", gender: :male, rng: Random.new(5), variant: "african_american")
      expect(pool).to include(name)
    end

    it "holds names specific to the variant" do
      expect(pool).to include("DeShawn")
    end
  end

  describe "Russia" do
    let(:native) { described_class.first_names(country: "RU", gender: :male, script: :native) }
    let(:latin) { described_class.first_names(country: "RU", gender: :male, script: :latin) }

    it "exposes both scripts" do
      expect(described_class.scripts(country: "RU")).to eq(%i[latin native])
    end

    it "has a non-empty native pool" do
      expect(native).not_to be_empty
    end

    it "has a non-empty Latin pool" do
      expect(latin).not_to be_empty
    end

    it "keeps the native pool Cyrillic" do
      expect(native).to all(satisfy { |s| ScriptClassifier.script_of(s) == :cyrillic })
    end

    it "keeps the Latin pool Latin" do
      expect(latin).to all(satisfy { |s| ScriptClassifier.script_of(s) == :latin })
    end
  end

  describe "Latin-native countries" do
    %w[DE IT].each do |cc|
      it "reports Latin only for #{cc}" do
        expect(described_class.scripts(country: cc)).to eq(%i[latin])
      end

      it "keeps the #{cc} pool free of non-Latin noise" do
        pool = described_class.first_names(country: cc, gender: :male)
        expect(pool).to all(satisfy { |s| ScriptClassifier.script_of(s) == :latin })
      end
    end
  end

  describe "curated countries" do
    %w[CN UA].each do |cc|
      it "leaves #{cc} Latin-only" do
        expect(described_class.scripts(country: cc)).to eq(%i[latin])
      end
    end
  end
end
