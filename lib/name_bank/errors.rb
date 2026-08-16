# frozen_string_literal: true

# Declared as a class, not a module: NameBank itself is one (see lib/name_bank.rb).
class NameBank
  # Mixed into every error this gem raises, so `rescue NameBank::Error` catches
  # all of them while each error keeps its natural superclass. Errors whose
  # valid values are a fixed, countable set are ArgumentErrors; errors that
  # depend on what a data dir happens to hold are not.
  module Error; end

  # No pool file for this country code.
  class UnknownCountry < StandardError
    include Error
  end

  # No pool file for this variant of this country.
  class UnknownVariant < StandardError
    include Error
  end

  # A pool file is missing a schema key, or holds something other than a list.
  class MalformedPool < StandardError
    include Error
  end

  # The requested pool exists but holds no names.
  class EmptyPool < StandardError
    include Error
  end

  # More distinct pairs were asked for than the pools can form.
  class PoolExhausted < StandardError
    include Error
  end

  # script: was neither :latin nor :native.
  class UnknownScript < ArgumentError
    include Error
  end

  # gender: was neither :male nor :female.
  class UnknownGender < ArgumentError
    include Error
  end
end
