# frozen_string_literal: true

require "spec_helper"

RSpec.describe NameBank do
  it "has a version" do
    expect(NameBank::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end

RSpec.describe "NameBank sampling" do
  before do
    # Point the module at fixtures instead of the real data/ dir.
    NameBank.instance_variable_set(:@repository,
      NameBank::Repository.new(data_dir: FIXTURE_DATA_DIR))
  end

  after { NameBank.instance_variable_set(:@repository, nil) }

  it "samples a male first name from the country pool" do
    name = NameBank.first_name(country: "XX", gender: :male, rng: Random.new(1))
    expect(%w[Xavier Xander Xeno]).to include(name)
  end

  it "samples a female first name only from the female pool" do
    names = 50.times.map { NameBank.first_name(country: "XX", gender: :female, rng: Random.new(_1)) }
    expect(names).to all(satisfy { |n| %w[Xena Ximena Xiu].include?(n) })
    expect(names).not_to include("Xavier")
  end

  it "is deterministic for the same rng seed" do
    a = NameBank.full_name(country: "XX", gender: :male, rng: Random.new(42))
    b = NameBank.full_name(country: "XX", gender: :male, rng: Random.new(42))
    expect(a).to eq(b)
    expect(a).to eq({ firstname: a[:firstname], lastname: a[:lastname] })
  end

  it "returns a full name hash" do
    result = NameBank.full_name(country: "YY", gender: :female, rng: Random.new(7))
    expect(result.keys).to contain_exactly(:firstname, :lastname)
    expect(%w[Yara Yuki]).to include(result[:firstname])
    expect(%w[York Yamada]).to include(result[:lastname])
  end

  it "samples from a variant pool when variant is given" do
    name = NameBank.first_name(country: "XX", gender: :male, rng: Random.new(3), variant: "testvariant")
    expect(%w[Vmale1 Vmale2]).to include(name)
  end

  it "samples a last name from a variant pool when variant is given" do
    name = NameBank.last_name(country: "XX", rng: Random.new(3), variant: "testvariant")
    expect(%w[Vlast1 Vlast2]).to include(name)
  end

  it "exposes variants for a country" do
    expect(NameBank.variants(country: "XX")).to eq(%w[testvariant])
  end
end
