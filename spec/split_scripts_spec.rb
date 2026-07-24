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

    context "with an allowlisted country" do
      let(:out) { described_class.split_country("RU", data) }

      it "keeps the base first name pool Latin-only" do
        expect(out["firstnames_male"]).to eq(%w[Dmitry])
      end

      it "keeps only the country's own script in the native first name pool" do
        expect(out["firstnames_male_native"]).to eq(%w[Алексей]) # Han and Arabic dropped
      end

      it "keeps the base last name pool Latin-only" do
        expect(out["lastnames"]).to eq(%w[Ivanov])
      end

      it "fills the native last name pool" do
        expect(out["lastnames_native"]).to eq(%w[Иванов])
      end

      it "carries the source through" do
        expect(out["source"]).to eq("dataset")
      end
    end

    context "with a country that is not allowlisted" do
      let(:out) { described_class.split_country("IT", data) }

      it "keeps the male pool Latin-only" do
        expect(out["firstnames_male"]).to eq(%w[Dmitry])
      end

      it "keeps the female pool Latin-only" do
        expect(out["firstnames_female"]).to eq(%w[Anna])
      end

      it "writes no native key at all" do
        expect(out).not_to have_key("firstnames_male_native")
      end
    end

    context "with a pool larger than LIMIT" do
      let(:data) do
        { "source" => "dataset",
          "firstnames_male" => (1..2000).map { |i| "N#{i}" },
          "firstnames_female" => [], "lastnames" => [] }
      end
      let(:out) { described_class.split_country("IT", data) }

      it "caps the pool at LIMIT" do
        expect(out["firstnames_male"].size).to eq(SplitScripts::LIMIT)
      end

      it "caps it in order, keeping the first names" do
        expect(out["firstnames_male"].first).to eq("N1")
      end
    end

    context "when re-splitting already-split data" do
      let(:once) { described_class.split_country("RU", data) }
      let(:twice) { described_class.split_country("RU", once) }

      it "reproduces the previous output" do
        expect(twice).to eq(once)
      end

      it "keeps the native pool instead of dropping it" do
        expect(twice["firstnames_male_native"]).to eq(%w[Алексей])
      end
    end
  end
end
