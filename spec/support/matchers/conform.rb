# frozen_string_literal: true

require "rspec/expectations"
require "json"

RSpec::Matchers.define :not_conform_with do |expected_errors|
  def to_h(error)
    attrs = {}
    error.instance_variables.each do |var|
      var = var.to_s.delete("@")
      attrs[var.to_sym] = error.public_send(var)
    end

    attrs[:children] = attrs[:children].map do |child_error|
      to_h(child_error)
    end

    attrs
  end

  actual_errors = []
  size_ok = false
  status_ok = false
  match do |actual|
    expect(actual.size).to be(2)
    size_ok = true
    expect(actual.first).to be(:error)
    status_ok = true

    errors = actual[1]
    errors.each_with_index do |actual_error, i|
      actual_attributes = to_h(actual_error)
      actual_errors.push(actual_attributes)
      expect(actual_attributes.to_json).to eql(expected_errors[i].to_json)
    end

    expect(errors.size).to eql(expected_errors.size)
  end

  failure_message do |actual|
    if !size_ok
      "expected that the value is an array of length 2, was #{actual.size}"
    elsif !status_ok
      "expected that the value has status :error, was #{actual.first.inspect}"
    else
      "expected that the definition does not conform
      Expected errors:\n #{JSON.pretty_generate(expected_errors)}
      Actual errors:\n #{JSON.pretty_generate(actual_errors)}"
    end
  end
end

RSpec::Matchers.define :conform_with do |expected_value|
  size_ok = false
  status_ok = false
  match do |actual|
    expect(actual.size).to be(2)
    size_ok = true
    expect(actual.first).to be(:ok)
    status_ok = true

    expect(actual.last).to eql(expected_value)
  end

  failure_message do |actual|
    if !size_ok
      "expected that the value is an array of length 2, was #{actual.size}"
    elsif !status_ok
      "expected that the value has status :ok, was #{actual.first.inspect}"
    else
      "expected that the definition does conform
      Expected value:\n #{expected_value.inspect}
      Actual value:\n #{actual.last.inspect}"
    end
  end
end
