# frozen_string_literal: true

require "spec_helper"
require_relative "../tools/split_scripts"

RSpec.describe SplitScripts do
  describe ".split_country" do
    let(:data) do
      {
        "source" => "dataset",
        "firstnames_male" => %w[Dmitry Алексей 田中 محمد],
        "firstnames_female" => %w[Anna Ольга],
        "lastnames" => %w[Ivanov Иванов]
      }
    end

    it "splits an allowlisted country into Latin base + native keys, dropping noise" do
      out = described_class.split_country("RU", data)
      expect(out["firstnames_male"]).to eq(%w[Dmitry])          # Latin only
      expect(out["firstnames_male_native"]).to eq(%w[Алексей])  # Cyrillic only (Han/Arabic dropped)
      expect(out["lastnames"]).to eq(%w[Ivanov])
      expect(out["lastnames_native"]).to eq(%w[Иванов])
      expect(out["source"]).to eq("dataset")
    end

    it "keeps a non-allowlisted country Latin-only and drops all non-Latin" do
      out = described_class.split_country("IT", data)
      expect(out["firstnames_male"]).to eq(%w[Dmitry])
      expect(out).not_to have_key("firstnames_male_native")
      expect(out["firstnames_female"]).to eq(%w[Anna])
    end

    it "caps each pool at LIMIT in order" do
      big = { "source" => "dataset",
              "firstnames_male" => (1..2000).map { |i| "N#{i}" },
              "firstnames_female" => [], "lastnames" => [] }
      out = described_class.split_country("IT", big)
      expect(out["firstnames_male"].size).to eq(SplitScripts::LIMIT)
      expect(out["firstnames_male"].first).to eq("N1")
    end

    it "is idempotent — re-splitting already-split data reproduces it" do
      once = described_class.split_country("RU", data)
      twice = described_class.split_country("RU", once)
      expect(twice).to eq(once)
      expect(twice["firstnames_male_native"]).to eq(%w[Алексей])
    end
  end
end
