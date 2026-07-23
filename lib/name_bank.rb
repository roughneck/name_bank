# frozen_string_literal: true

require_relative "name_bank/version"
require_relative "name_bank/repository"

module NameBank
  Error = Class.new(StandardError)
  UnknownCountry = Class.new(Error)
  UnknownVariant = Class.new(Error)
end
