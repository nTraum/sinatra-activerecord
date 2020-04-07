# frozen_string_literal: true

require 'open3'
require 'rspec/expectations'

RSpec::Matchers.define :run_process do
  match do |actual|
    stdout, stderr, status = Open3.capture3(*actual)
    @result = { stdout: stdout.strip, stderr: stderr.strip, status: status.to_i }
    expected = { stdout: stdout.strip, stderr: stderr.strip, status: 0 }

    values_match? expected, @result
  end

  failure_message do |actual|
    <<~MESSAGE.strip
      expected that #{actual} would run and exit with 0, instead:
      status: #{@result[:status]}
      stdout: #{@result[:stdout]}
      stderr: #{@result[:stderr]}
    MESSAGE
  end

  failure_message_when_negated do |actual|
    <<~MESSAGE.strip
      expected that #{actual} would run and exit non-zero, instead:
      status: #{@result[:status]}
      stdout: #{@result[:stdout]}
      stderr: #{@result[:stderr]}
    MESSAGE
  end

  diffable
end
