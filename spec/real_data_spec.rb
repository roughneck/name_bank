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
end
