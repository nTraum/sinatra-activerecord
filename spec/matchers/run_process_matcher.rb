# frozen_string_literal: true

require 'open3'
require 'rspec/expectations'

RSpec::Matchers.define :run_process do
  match do |actual|
    stdout, stderr, status = Open3.capture3(*actual)

    @actual = [stdout, stderr, status.to_i]

    expected = [stdout, stderr, 0]

    values_match? expected, @actual
  end

  failure_message do |actual|
    "expected that #{actual} would run and exit with 0, instead: #{expected}"
  end

  diffable
end
