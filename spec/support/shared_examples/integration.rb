shared_examples "it conforms" do |value|
  it "passes validation for #{value}" do
    result = definition.conform(value)
    expect(result.passed?).to be_truthy, result.error_message
  end

  it "returns #{value}" do
    expect(definition.conform(value).result).to eql(value)
  end
end

shared_examples "it conforms via coersion" do |input:, output:|
  it "passes validation for #{input}" do
    result = definition.conform(input)
    expect(result.passed?).to be_truthy, result.error_message
  end

  it "coerces #{input} to #{output}" do
    result = definition.conform(input)
    expect(result.result).to eql(output), result.error_message
  end
end

shared_examples "it does not conform" do
  it "does not passes validation" do
    expect(definition.conform(value).passed?).to be_falsy
  end

  it "has correct error message" do
    verify(format: :text) { definition.conform(value).error_message }
  end
end
