# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pry"
require "definition"
require "awesome_print"
require "rspec/its"
require "approvals/rspec"
require "timecop"

Dir[File.expand_path("support/**/*rb", __dir__)].each do |support_file|
  require support_file
end

RSpec.configure do |config|
  config.include SpecHelpers

  config.approvals_path = "spec/approvals/"
  config.diff_on_approval_failure = true

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.default_formatter = "doc" if config.files_to_run.one?
  config.profile_examples = 5

  config.order = :random
  Kernel.srand config.seed
end
