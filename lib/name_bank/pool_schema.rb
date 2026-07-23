# frozen_string_literal: true

module NameBank
  # The pool-key schema: the base YAML keys, how native-script keys are named,
  # and how a gender maps to its key. Shared by the runtime Repository and the
  # build-time SplitScripts tool so the key names live in one place.
  module PoolSchema
    KEYS = %w[firstnames_male firstnames_female lastnames].freeze

    module_function

    def native_key(key)
      "#{key}_native"
    end

    def gender_key(gender)
      case gender
      when :male then "firstnames_male"
      when :female then "firstnames_female"
      else raise ArgumentError, "gender must be :male or :female, got #{gender.inspect}"
      end
    end
  end
end
