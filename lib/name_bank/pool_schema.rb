# frozen_string_literal: true

require_relative "errors"

# Declared as a class, not a module: NameBank itself is one (see lib/name_bank.rb).
class NameBank
  # The pool-key schema: the base YAML keys, how native-script keys are named,
  # and how a gender maps to its key. Shared by the runtime NameBank and the
  # build-time SplitScripts tool so the key names live in one place.
  module PoolSchema
    GIVEN_MALE = "firstnames_male"
    GIVEN_FEMALE = "firstnames_female"
    SURNAMES = "lastnames"

    KEYS = [GIVEN_MALE, GIVEN_FEMALE, SURNAMES].freeze

    module_function

    def native_key(key)
      "#{key}_native"
    end

    def gender_key(gender)
      case gender
      when :male then GIVEN_MALE
      when :female then GIVEN_FEMALE
      else raise UnknownGender, "gender must be :male or :female, got #{gender.inspect}"
      end
    end
  end
end
