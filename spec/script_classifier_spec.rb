# frozen_string_literal: true

require "spec_helper"
require_relative "../tools/script_classifier"

RSpec.describe ScriptClassifier do
  describe ".script_of" do
    it "treats ASCII and Latin diacritics as Latin" do
      expect(described_class.script_of("David")).to eq(:latin)
      expect(described_class.script_of("Müller")).to eq(:latin)
      expect(described_class.script_of("José")).to eq(:latin)
      expect(described_class.script_of("Nguyễn")).to eq(:latin)
    end

    it "detects non-Latin scripts by the first non-Latin letter" do
      expect(described_class.script_of("Алексей")).to eq(:cyrillic)
      expect(described_class.script_of("محمد")).to eq(:arabic)
      expect(described_class.script_of("田中")).to eq(:han)
      expect(described_class.script_of("김민")).to eq(:hangul)
      expect(described_class.script_of("たなか")).to eq(:kana)
      expect(described_class.script_of("Ιωάννης")).to eq(:greek)
      expect(described_class.script_of("דוד")).to eq(:hebrew)
      expect(described_class.script_of("გიორგი")).to eq(:georgian)
    end

    it "classifies by the leading non-Latin letter when scripts are mixed" do
      expect(described_class.script_of("Ivan Иванов")).to eq(:cyrillic)
    end
  end
end
