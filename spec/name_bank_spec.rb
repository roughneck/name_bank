# frozen_string_literal: true

require "spec_helper"

# Exercises the interface against the fixture data dir. The class-level methods,
# which delegate to the default instance over the shipped data/ dir, are covered
# by name_bank_real_data_spec.rb.
RSpec.describe NameBank do
  subject(:bank) { described_class.new(data_dir: FIXTURE_DATA_DIR) }

  it "has a version" do
    expect(NameBank::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end

  it "defaults to the shipped data dir" do
    expect(described_class.new.countries.size).to be >= 100
  end

  it "no longer exposes a repository" do
    expect(described_class).not_to respond_to(:repository)
  end

  describe "#first_names" do
    it "returns the male pool" do
      expect(bank.first_names(country: "XX", gender: :male)).to eq(%w[Xavier Xander Xeno])
    end

    it "returns the female pool" do
      expect(bank.first_names(country: "XX", gender: :female)).to eq(%w[Xena Ximena Xiu])
    end

    it "returns a frozen array" do
      expect(bank.first_names(country: "XX", gender: :male)).to be_frozen
    end

    it "returns the variant pool when variant is given" do
      expect(bank.first_names(country: "XX", gender: :male, variant: "testvariant")).to eq(%w[Vmale1 Vmale2])
    end

    it "returns the native pool for script: :native" do
      expect(bank.first_names(country: "ZZ", gender: :male, script: :native)).to eq(%w[Захар Зиновий])
    end

    it "falls back to the Latin pool when the country has no native keys" do
      expect(bank.first_names(country: "XX", gender: :male, script: :native)).to eq(%w[Xavier Xander Xeno])
    end

    it "defaults to the Latin pool" do
      expect(bank.first_names(country: "ZZ", gender: :male)).to eq(%w[Zed Zane])
    end

    it "raises for an unknown country" do
      expect { bank.first_names(country: "UU", gender: :male) }
        .to raise_error(NameBank::UnknownCountry, "UU")
    end

    it "raises for an invalid gender" do
      expect { bank.first_names(country: "XX", gender: :other) }
        .to raise_error(NameBank::UnknownGender, /gender must be :male or :female/)
    end

    it "raises for an unknown variant" do
      expect { bank.first_names(country: "XX", gender: :male, variant: "nope") }
        .to raise_error(NameBank::UnknownVariant, "XX/nope")
    end

    it "raises UnknownScript for an unknown script" do
      expect { bank.first_names(country: "ZZ", gender: :male, script: :klingon) }
        .to raise_error(NameBank::UnknownScript, /script must be :latin or :native/)
    end

    it "raises EmptyPool for a genuinely empty pool" do
      expect { bank.first_names(country: "QQ", gender: :male, script: :latin) }
        .to raise_error(NameBank::EmptyPool, "QQ/latin")
    end
  end

  describe "#last_names" do
    it "returns the pool" do
      expect(bank.last_names(country: "XX")).to eq(%w[Xu Xander Ximenez])
    end

    it "returns a frozen array" do
      expect(bank.last_names(country: "XX")).to be_frozen
    end

    it "returns the variant pool when variant is given" do
      expect(bank.last_names(country: "XX", variant: "testvariant")).to eq(%w[Vlast1 Vlast2])
    end

    it "returns the native pool for script: :native" do
      expect(bank.last_names(country: "ZZ", script: :native)).to eq(%w[Захаров Зимин])
    end

    it "raises for a variant on an unknown country" do
      expect { bank.last_names(country: "UU", variant: "testvariant") }
        .to raise_error(NameBank::UnknownVariant, "UU/testvariant")
    end
  end

  describe "#first_name" do
    it "samples a male first name from the country pool" do
      pool = %w[Xavier Xander Xeno]
      expect(pool).to include(bank.first_name(country: "XX", gender: :male, rng: Random.new(1)))
    end

    it "samples from a variant pool when variant is given" do
      pool = %w[Vmale1 Vmale2]
      expect(pool).to include(bank.first_name(country: "XX", gender: :male, rng: Random.new(3),
                                              variant: "testvariant"))
    end

    it "samples a native first name for script: :native" do
      pool = %w[Захар Зиновий]
      expect(pool).to include(bank.first_name(country: "ZZ", gender: :male, rng: Random.new(3), script: :native))
    end

    context "when drawing many female samples" do
      let(:names) do
        Array.new(50) { |seed| bank.first_name(country: "XX", gender: :female, rng: Random.new(seed)) }
      end

      it "only yields names from the female pool" do
        expect(names).to all(satisfy { |n| %w[Xena Ximena Xiu].include?(n) })
      end

      it "never yields a name from the male pool" do
        expect(names).not_to include("Xavier")
      end
    end
  end

  describe "#last_name" do
    it "samples a last name from a variant pool when variant is given" do
      pool = %w[Vlast1 Vlast2]
      expect(pool).to include(bank.last_name(country: "XX", rng: Random.new(3), variant: "testvariant"))
    end

    it "samples a native last name for script: :native" do
      pool = %w[Захаров Зимин]
      expect(pool).to include(bank.last_name(country: "ZZ", rng: Random.new(3), script: :native))
    end
  end

  describe "#full_name" do
    it "is deterministic for the same rng seed" do
      a = bank.full_name(country: "XX", gender: :male, rng: Random.new(42))
      b = bank.full_name(country: "XX", gender: :male, rng: Random.new(42))
      expect(a).to eq(b)
    end

    it "returns nothing but a firstname and a lastname" do
      result = bank.full_name(country: "XX", gender: :male, rng: Random.new(42))
      expect(result.keys).to contain_exactly(:firstname, :lastname)
    end

    context "with country YY" do
      let(:result) { bank.full_name(country: "YY", gender: :female, rng: Random.new(7)) }

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
      let(:result) { bank.full_name(country: "ZZ", gender: :female, rng: Random.new(8), script: :native) }

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
      let(:result) { bank.full_name(country: "ZZ", gender: :male, rng: Random.new(8)) }

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

  describe "#countries" do
    it "lists available countries sorted" do
      expect(bank.countries).to eq(%w[QQ XX YY ZZ])
    end
  end

  describe "#variants" do
    it "exposes variants for a country" do
      expect(bank.variants(country: "XX")).to eq(%w[testvariant])
    end

    it "returns no variants for a country without any" do
      expect(bank.variants(country: "YY")).to eq([])
    end

    it "reads the directory once per country" do
      allow(Dir).to receive(:children).and_call_original
      2.times { bank.variants(country: "XX") }
      expect(Dir).to have_received(:children).once
    end
  end

  describe "#scripts" do
    it "reports both scripts for a country with a native pool" do
      expect(bank.scripts(country: "ZZ")).to eq(%i[latin native])
    end

    it "reports Latin only for a country without a native pool" do
      expect(bank.scripts(country: "XX")).to eq(%i[latin])
    end
  end

  describe "the error hierarchy" do
    let(:malformed) { described_class.new(data_dir: MALFORMED_DATA_DIR) }

    it "is a module, so each error keeps its natural superclass" do
      expect(NameBank::Error).not_to be_a(Class)
    end

    %i[UnknownCountry UnknownVariant UnknownScript UnknownGender EmptyPool MalformedPool].each do |name|
      it "tags #{name} as a NameBank error" do
        expect(described_class.const_get(name).ancestors).to include(NameBank::Error)
      end
    end

    it "makes an unknown gender an ArgumentError" do
      expect(NameBank::UnknownGender.ancestors).to include(ArgumentError)
    end

    it "makes an unknown script an ArgumentError" do
      expect(NameBank::UnknownScript.ancestors).to include(ArgumentError)
    end

    it "keeps an unknown country out of ArgumentError" do
      expect(NameBank::UnknownCountry.ancestors).not_to include(ArgumentError)
    end

    it "rescues an unknown country as a NameBank error" do
      expect { bank.first_names(country: "UU", gender: :male) }.to raise_error(NameBank::Error)
    end

    it "raises MalformedPool for a file missing a pool key" do
      expect { malformed.first_names(country: "AA", gender: :male) }
        .to raise_error(NameBank::MalformedPool, /lastnames/)
    end

    it "names the offending file in the message" do
      expect { malformed.first_names(country: "AA", gender: :male) }
        .to raise_error(NameBank::MalformedPool, %r{malformed/countries/AA\.yml})
    end

    it "raises MalformedPool when a pool is not an array" do
      expect { malformed.first_names(country: "BB", gender: :male) }
        .to raise_error(NameBank::MalformedPool, /firstnames_male/)
    end

    it "validates before the key is read, so KeyError never escapes" do
      expect { malformed.last_names(country: "AA") }.to raise_error(NameBank::MalformedPool)
    end
  end

  describe "caching" do
    it "loads a country file once" do
      allow(YAML).to receive(:safe_load_file).and_call_original
      2.times { bank.first_names(country: "XX", gender: :male) }
      expect(YAML).to have_received(:safe_load_file).once
    end

    it "keeps separate instances independent" do
      expect(described_class.new(data_dir: FIXTURE_DATA_DIR).countries).to eq(bank.countries)
    end
  end
end
