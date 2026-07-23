# frozen_string_literal: true

require "spec_helper"

RSpec.describe "committed data" do
  # Uses the real data/ dir via the default repository.
  before { NameBank.instance_variable_set(:@repository, nil) }
  after  { NameBank.instance_variable_set(:@repository, nil) }

  it "ships a healthy number of countries" do
    expect(NameBank.countries.size).to be >= 100
  end

  it "loads every country with non-empty, capped pools" do
    NameBank.countries.each do |cc|
      male = NameBank.repository.firstnames(country: cc, gender: :male)
      female = NameBank.repository.firstnames(country: cc, gender: :female)
      last = NameBank.repository.lastnames(country: cc)

      [male, female, last].each do |pool|
        expect(pool).to be_a(Array), "#{cc}: pool not an array"
        expect(pool.size).to be_between(1, 1500), "#{cc}: pool size #{pool.size} out of range"
        expect(pool).to all(be_a(String))
      end
    end
  end

  it "samples a deterministic full name for a major country" do
    a = NameBank.full_name(country: "DE", gender: :male, rng: Random.new(99))
    b = NameBank.full_name(country: "DE", gender: :male, rng: Random.new(99))
    expect(a).to eq(b)
    expect(a[:firstname]).to be_a(String).and(satisfy { !_1.empty? })
  end

  it "includes curated Ukraine with gendered pools" do
    expect(NameBank.countries).to include("UA")
    male = NameBank.first_name(country: "UA", gender: :male, rng: Random.new(1))
    female = NameBank.first_name(country: "UA", gender: :female, rng: Random.new(1))
    expect(male).to be_a(String)
    expect(female).to be_a(String)
    expect(NameBank.repository.firstnames(country: "UA", gender: :male))
      .not_to include(*NameBank.repository.firstnames(country: "UA", gender: :female))
  end

  it "uses a clean curated pinyin pool for China (no dataset pollution)" do
    male = NameBank.repository.firstnames(country: "CN", gender: :male)
    female = NameBank.repository.firstnames(country: "CN", gender: :female)
    expect(male).to include("Wei")
    expect(female).to include("Mei")
    # The broken dataset pool leaked Western given names; the curated pool must not.
    expect(male).not_to include("Jason")
    expect(female).not_to include("Lily")
  end

  it "exposes the US african_american variant and samples from it" do
    expect(NameBank.variants(country: "US")).to include("african_american")
    aa_pool = NameBank.repository.firstnames(country: "US", gender: :male, variant: "african_american")
    name = NameBank.first_name(country: "US", gender: :male, rng: Random.new(5), variant: "african_american")
    expect(aa_pool).to include(name)
    expect(aa_pool).to include("DeShawn")
  end

  it "exposes a native Cyrillic pool for Russia alongside a Latin pool" do
    expect(NameBank.scripts(country: "RU")).to eq(%i[latin native])
    native = NameBank.repository.firstnames(country: "RU", gender: :male, script: :native)
    latin = NameBank.repository.firstnames(country: "RU", gender: :male, script: :latin)
    expect(native).not_to be_empty
    expect(latin).not_to be_empty
    cyrillic = ->(s) { s.each_char.any? { |c| c.ord.between?(0x0400, 0x04FF) } }
    expect(native).to all(satisfy(&cyrillic))
    expect(latin).to all(satisfy { |s| !cyrillic.call(s) })
  end

  it "keeps Latin-native countries free of native keys and non-Latin noise" do
    %w[DE IT].each do |cc|
      expect(NameBank.scripts(country: cc)).to eq(%i[latin])
      pool = NameBank.repository.firstnames(country: cc, gender: :male)
      # Check for foreign scripts (Arabic, Cyrillic, Han, Greek, etc.), not just ord > 0x024F
      # which would reject valid Latin combining marks like Vietnamese diacritics.
      foreign_scripts = {
        arabic: [0x0600..0x06FF, 0x0750..0x077F],
        cyrillic: [0x0400..0x04FF],
        han: [0x4E00..0x9FFF, 0x3400..0x4DBF],
        greek: [0x0370..0x03FF],
        hebrew: [0x0590..0x05FF],
        hangul: [0xAC00..0xD7AF],
        kana: [0x3040..0x30FF],
        georgian: [0x10A0..0x10FF],
        khmer: [0x1780..0x17FF],
        bengali: [0x0980..0x09FF],
        devanagari: [0x0900..0x097F],
        thai: [0x0E00..0x0E7F]
      }
      has_foreign = ->(s) do
        s.each_char.any? do |c|
          cp = c.ord
          foreign_scripts.any? { |_script, ranges| ranges.any? { |r| r.cover?(cp) } }
        end
      end
      expect(pool).to all(satisfy { |s| !has_foreign.call(s) })
    end
  end

  it "leaves curated CN/UA Latin-only" do
    expect(NameBank.scripts(country: "CN")).to eq(%i[latin])
    expect(NameBank.scripts(country: "UA")).to eq(%i[latin])
  end
end
