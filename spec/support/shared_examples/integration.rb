# frozen_string_literal: true

shared_examples "it conforms" do |value|
  it "passes validation for #{value}" do
    result = definition.conform(value)
    expect(result.passed?).to be_truthy, result.error_message
  end

  it "returns #{value}" do
    expect(definition.conform(value).value).to eql(value)
  end
end

shared_examples "it conforms via coersion" do |input:, output:|
  it "passes validation for #{input}" do
    result = definition.conform(input)
    expect(result.passed?).to be_truthy, result.error_message
  end

  it "coerces #{input} to #{output}" do
    result = definition.conform(input)
    expect(result.value).to eql(output), result.error_message
  end
end

shared_examples "it does not conform" do
  it "does not passes validation" do
    expect(definition.conform(value)).not_to be_passed
  end

  it "has correct error message" do
    verify { definition.conform(value).error_message }
  end
end
