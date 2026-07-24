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
    expect(repo.countries).to eq(%w[QQ XX YY ZZ])
  end

  it "raises for an unknown country" do
    expect { repo.firstnames(country: "UU", gender: :male) }
      .to raise_error(NameBank::UnknownCountry, "UU")
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

  it "lists variants for a country" do
    expect(repo.variants(country: "XX")).to eq(%w[testvariant])
  end

  it "returns no variants for a country without any" do
    expect(repo.variants(country: "YY")).to eq([])
  end

  it "raises for an unknown variant" do
    expect { repo.firstnames(country: "XX", gender: :male, variant: "nope") }
      .to raise_error(NameBank::UnknownVariant, "XX/nope")
  end

  it "loads last names from a variant pool" do
    expect(repo.lastnames(country: "XX", variant: "testvariant")).to eq(%w[Vlast1 Vlast2])
  end

  it "raises for a variant on an unknown country" do
    expect { repo.lastnames(country: "UU", variant: "testvariant") }
      .to raise_error(NameBank::UnknownVariant, "UU/testvariant")
  end

  it "returns the native pool for script: :native" do
    expect(repo.firstnames(country: "ZZ", gender: :male, script: :native))
      .to eq(%w[Захар Зиновий])
  end

  it "returns the Latin base pool for script: :native when there are no native keys" do
    expect(repo.firstnames(country: "XX", gender: :male, script: :native))
      .to eq(%w[Xavier Xander Xeno])
  end

  it "defaults to the Latin pool" do
    expect(repo.firstnames(country: "ZZ", gender: :male)).to eq(%w[Zed Zane])
  end

  it "returns native last names for script: :native" do
    expect(repo.lastnames(country: "ZZ", script: :native)).to eq(%w[Захаров Зимин])
  end

  it "reports [:latin, :native] for a country with a native pool" do
    expect(repo.scripts(country: "ZZ")).to eq(%i[latin native])
  end

  it "reports [:latin] for a Latin-only country" do
    expect(repo.scripts(country: "XX")).to eq(%i[latin])
  end

  it "raises ArgumentError for an unknown script" do
    expect { repo.firstnames(country: "ZZ", gender: :male, script: :klingon) }
      .to raise_error(ArgumentError, /script must be :latin or :native/)
  end

  it "raises UnknownScript for a genuinely empty pool" do
    expect { repo.firstnames(country: "QQ", gender: :male, script: :latin) }
      .to raise_error(NameBank::UnknownScript, "QQ/latin")
  end
end
