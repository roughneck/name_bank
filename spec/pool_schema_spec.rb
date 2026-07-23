# frozen_string_literal: true

require "spec_helper"

RSpec.describe NameBank::PoolSchema do
  it "lists the base pool keys" do
    expect(described_class::KEYS).to eq(%w[firstnames_male firstnames_female lastnames])
  end

  it "derives the native key from a base key" do
    expect(described_class.native_key("firstnames_male")).to eq("firstnames_male_native")
    expect(described_class.native_key("lastnames")).to eq("lastnames_native")
  end

  it "maps gender to its base key" do
    expect(described_class.gender_key(:male)).to eq("firstnames_male")
    expect(described_class.gender_key(:female)).to eq("firstnames_female")
  end

  it "raises for an invalid gender" do
    expect { described_class.gender_key(:other) }
      .to raise_error(ArgumentError, /gender must be :male or :female/)
  end
end
