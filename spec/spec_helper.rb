# frozen_string_literal: true

require "name_bank"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end

FIXTURE_DATA_DIR = File.expand_path("fixtures/data", __dir__)

# Pool files that violate the schema on purpose: AA.yml is missing a key,
# BB.yml holds a String where a pool belongs.
MALFORMED_DATA_DIR = File.expand_path("fixtures/malformed", __dir__)
