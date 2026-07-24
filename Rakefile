# frozen_string_literal: true

require "rspec/core/rake_task"
require "rubocop/rake_task"
require "bundler/audit/task"

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new
Bundler::Audit::Task.new

# The default task stays offline-capable, so it audits against whatever advisory
# DB is already on disk.
task default: %i[spec rubocop bundle:audit:check]

# Refreshes the advisory DB first, so the audit is current where it matters.
desc "Full pre-release check with a fresh advisory DB"
task release_check: %i[spec rubocop bundle:audit:update bundle:audit:check]
