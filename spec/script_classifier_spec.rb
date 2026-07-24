# frozen_string_literal: true

require "spec_helper"
require_relative "../tools/script_classifier"

RSpec.describe ScriptClassifier do
  describe ".script_of" do
    context "with Latin names" do
      %w[David Müller José Nguyễn].each do |name|
        it "treats #{name} as Latin" do
          expect(described_class.script_of(name)).to eq(:latin)
        end
      end
    end

    context "with non-Latin names" do
      {
        "Алексей" => :cyrillic,
        "محمد" => :arabic,
        "田中" => :han,
        "김민" => :hangul,
        "たなか" => :kana,
        "Ιωάννης" => :greek,
        "דוד" => :hebrew,
        "გიორგი" => :georgian
      }.each do |name, script|
        it "detects #{script} from the first non-Latin letter of #{name}" do
          expect(described_class.script_of(name)).to eq(script)
        end
      end
    end

    it "classifies by the leading non-Latin letter when scripts are mixed" do
      expect(described_class.script_of("Ivan Иванов")).to eq(:cyrillic)
    end
  end
end
