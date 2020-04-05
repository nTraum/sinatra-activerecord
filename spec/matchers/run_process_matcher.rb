# frozen_string_literal: true

require 'open3'
require 'rspec/expectations'

RSpec::Matchers.define :run_process do
  match do |actual|
    stdout, stderr, status = Open3.capture3(*actual)
    @result = [stdout, stderr, status.to_i]

    puts stdout

    expected = [stdout, stderr, 0]

    values_match? expected, @result
  end

  failure_message do |actual|
    "expected that #{actual} would run and exit with 0, instead: #{@result}"
  end

  failure_message_when_negated do |actual|
    "expected that #{actual} would fail and exit non-zero, instead: #{@result}"
  end

  diffable
end
