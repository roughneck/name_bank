# frozen_string_literal: true

require_relative "name_bank/version"

module NameBank
  Error = Class.new(StandardError)
  UnknownCountry = Class.new(Error)
  UnknownVariant = Class.new(Error)
end
