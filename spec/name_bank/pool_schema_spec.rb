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
      .to raise_error(NameBank::UnknownGender, /gender must be :male or :female/)
  end

  # The README documents PoolSchema as supported API from 0.2.0 on. These two
  # lock the guarantees it makes that nothing else asserts.
  it "freezes KEYS, as the README promises" do
    expect(described_class::KEYS).to be_frozen
  end

  it "raises an error a caller can rescue as ArgumentError" do
    expect(NameBank::UnknownGender.ancestors).to include(ArgumentError)
  end
end
