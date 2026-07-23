# frozen_string_literal: true

require "spec_helper"

RSpec.describe NameBank::Repository do
  subject(:repo) { described_class.new(data_dir: FIXTURE_DATA_DIR) }

  it "loads male first names for a country" do
    expect(repo.firstnames(country: "XX", gender: :male)).to eq(%w[Xavier Xander Xeno])
  end

  it "loads female first names for a country" do
    expect(repo.firstnames(country: "XX", gender: :female)).to eq(%w[Xena Ximena Xiu])
  end

  it "loads last names for a country" do
    expect(repo.lastnames(country: "XX")).to eq(%w[Xu Xander Ximenez])
  end

  it "lists available countries sorted" do
    expect(repo.countries).to eq(%w[XX YY])
  end

  it "raises for an unknown country" do
    expect { repo.firstnames(country: "ZZ", gender: :male) }
      .to raise_error(NameBank::UnknownCountry, "ZZ")
  end

  it "raises for an invalid gender" do
    expect { repo.firstnames(country: "XX", gender: :other) }
      .to raise_error(ArgumentError, /gender must be :male or :female/)
  end

  it "memoizes a country file (loads it once)" do
    require "yaml"
    allow(YAML).to receive(:safe_load_file).and_call_original
    2.times { repo.firstnames(country: "XX", gender: :male) }
    expect(YAML).to have_received(:safe_load_file).once
  end
end
