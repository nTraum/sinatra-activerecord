# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

if ENV['CODECOV_ENABLED'] == 'true'
  require 'codecov'

  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                    SimpleCov::Formatter::HTMLFormatter,
                                                                    SimpleCov::Formatter::Codecov
                                                                  ])
end

require 'bundler/setup'
require 'sinatra/activerecord'

require 'timecop'

require_relative 'matchers/run_process_matcher'
require_relative 'helpers/isolated_app_dir_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.default_formatter = 'doc' if config.files_to_run.one?
  config.disable_monkey_patching!
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.filter_run_when_matching :focus
  config.order = :random
  config.profile_examples = 10
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.warnings = true
  Kernel.srand config.seed

  config.include(IsolatedAppDirHelper)

  config.before(:suite) { Timecop.safe_mode = true }
end
