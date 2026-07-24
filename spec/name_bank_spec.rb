# frozen_string_literal: true

require "spec_helper"

RSpec.describe NameBank do
  before do
    # Point the module at fixtures instead of the real data/ dir.
    described_class.instance_variable_set(:@repository,
                                          NameBank::Repository.new(data_dir: FIXTURE_DATA_DIR))
  end

  after { described_class.instance_variable_set(:@repository, nil) }

  it "has a version" do
    expect(NameBank::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  describe ".first_name" do
    it "samples a male first name from the country pool" do
      pool = %w[Xavier Xander Xeno]
      name = described_class.first_name(country: "XX", gender: :male, rng: Random.new(1))
      expect(pool).to include(name)
    end

    it "samples from a variant pool when variant is given" do
      pool = %w[Vmale1 Vmale2]
      name = described_class.first_name(country: "XX", gender: :male, rng: Random.new(3), variant: "testvariant")
      expect(pool).to include(name)
    end

    it "samples a native first name for script: :native" do
      pool = %w[Захар Зиновий]
      name = described_class.first_name(country: "ZZ", gender: :male, rng: Random.new(3), script: :native)
      expect(pool).to include(name)
    end

    context "when drawing many female samples" do
      let(:names) do
        Array.new(50) { |seed| described_class.first_name(country: "XX", gender: :female, rng: Random.new(seed)) }
      end

      it "only yields names from the female pool" do
        expect(names).to all(satisfy { |n| %w[Xena Ximena Xiu].include?(n) })
      end

      it "never yields a name from the male pool" do
        expect(names).not_to include("Xavier")
      end
    end
  end

  describe ".last_name" do
    it "samples a last name from a variant pool when variant is given" do
      pool = %w[Vlast1 Vlast2]
      name = described_class.last_name(country: "XX", rng: Random.new(3), variant: "testvariant")
      expect(pool).to include(name)
    end

    it "samples a native last name for script: :native" do
      pool = %w[Захаров Зимин]
      name = described_class.last_name(country: "ZZ", rng: Random.new(3), script: :native)
      expect(pool).to include(name)
    end
  end

  describe ".full_name" do
    it "is deterministic for the same rng seed" do
      a = described_class.full_name(country: "XX", gender: :male, rng: Random.new(42))
      b = described_class.full_name(country: "XX", gender: :male, rng: Random.new(42))
      expect(a).to eq(b)
    end

    it "returns nothing but a firstname and a lastname" do
      result = described_class.full_name(country: "XX", gender: :male, rng: Random.new(42))
      expect(result.keys).to contain_exactly(:firstname, :lastname)
    end

    context "with country YY" do
      let(:result) { described_class.full_name(country: "YY", gender: :female, rng: Random.new(7)) }

      it "returns a firstname and a lastname" do
        expect(result.keys).to contain_exactly(:firstname, :lastname)
      end

      it "takes the firstname from the YY female pool" do
        pool = %w[Yara Yuki]
        expect(pool).to include(result[:firstname])
      end

      it "takes the lastname from the YY lastname pool" do
        pool = %w[York Yamada]
        expect(pool).to include(result[:lastname])
      end
    end

    context "with script: :native" do
      let(:result) { described_class.full_name(country: "ZZ", gender: :female, rng: Random.new(8), script: :native) }

      it "takes the firstname from the native pool" do
        pool = %w[Зоя Злата]
        expect(pool).to include(result[:firstname])
      end

      it "takes the lastname from the native pool" do
        pool = %w[Захаров Зимин]
        expect(pool).to include(result[:lastname])
      end
    end

    context "without a script" do
      let(:result) { described_class.full_name(country: "ZZ", gender: :male, rng: Random.new(8)) }

      it "takes the firstname from the Latin pool" do
        pool = %w[Zed Zane]
        expect(pool).to include(result[:firstname])
      end

      it "takes the lastname from the Latin pool" do
        pool = %w[Zimmer Zorn]
        expect(pool).to include(result[:lastname])
      end
    end
  end

  describe ".variants" do
    it "exposes variants for a country" do
      expect(described_class.variants(country: "XX")).to eq(%w[testvariant])
    end
  end

  describe ".scripts" do
    it "reports both scripts for a country with a native pool" do
      expect(described_class.scripts(country: "ZZ")).to eq(%i[latin native])
    end

    it "reports Latin only for a country without a native pool" do
      expect(described_class.scripts(country: "XX")).to eq(%i[latin])
    end
  end
end
