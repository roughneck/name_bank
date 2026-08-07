# frozen_string_literal: true

require "spec_helper"

RSpec.describe NameBank::PoolSchema do
  it "names the male given-name key" do
    expect(described_class::GIVEN_MALE).to eq("firstnames_male")
  end

  it "names the female given-name key" do
    expect(described_class::GIVEN_FEMALE).to eq("firstnames_female")
  end

  it "names the surname key" do
    expect(described_class::SURNAMES).to eq("lastnames")
  end

  it "lists the base pool keys" do
    expect(described_class::KEYS).to eq(%w[firstnames_male firstnames_female lastnames])
  end

  it "builds KEYS from the named constants, so no key string is written twice" do
    expect(described_class::KEYS)
      .to eq([described_class::GIVEN_MALE, described_class::GIVEN_FEMALE, described_class::SURNAMES])
  end

  it "derives the native key from a firstname key" do
    expect(described_class.native_key("firstnames_male")).to eq("firstnames_male_native")
  end

  it "derives the native key from the lastname key" do
    expect(described_class.native_key("lastnames")).to eq("lastnames_native")
  end

  it "maps :male to its base key" do
    expect(described_class.gender_key(:male)).to eq("firstnames_male")
  end

  it "maps :female to its base key" do
    expect(described_class.gender_key(:female)).to eq("firstnames_female")
  end

  it "raises for an invalid gender" do
    expect { described_class.gender_key(:other) }
      .to raise_error(ArgumentError, /gender must be :male or :female/)
  end
end
