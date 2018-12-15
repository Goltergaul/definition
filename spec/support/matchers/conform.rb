# frozen_string_literal: true

require "rspec/expectations"
require "json"

RSpec::Matchers.define :not_conform_with do |expected_message|
  match do |actual|
    expect(actual.passed?).to be_falsy
    expect(actual.error_message).to eql(expected_message)
  end

  failure_message do |actual|
    if actual.passed?
      "expected that it does not conform but it did"
    else
      "expected the following error message:\n
      Expected:\n #{expected_message}
      Actual:\n #{actual.error_message}"
    end
  end
end

RSpec::Matchers.define :conform_with do |expected_value|
  match do |actual|
    expect(actual.passed?).to be_truthy
    expect(actual.result).to eql(expected_value)
  end

  failure_message do |actual|
    if !actual.passed?
      "expected that it does conform but it did not"
    else
      "expected the following result:\n
      Expected:\n #{expected_value}
      Actual:\n #{actual.result}"
    end
  end
end
