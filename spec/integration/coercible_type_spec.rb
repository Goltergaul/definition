# frozen_string_literal: true

require "spec_helper"

describe "Definition.CoercibleType" do
  subject(:definition) do
    Definition.CoercibleType(Float)
  end

  it_behaves_like "it conforms", 9.99
  it_behaves_like "it conforms via coersion", input: "9.99", output: 9.99

  context "with incoercible string" do
    let(:value) { "abc" }

    it_behaves_like "it does not conform"
  end

  context "with incoercible nil value" do
    let(:value) { nil }

    it_behaves_like "it does not conform"
  end

  context "with incoercible error class instance" do
    let(:value) { StandardError.new("oops") }

    it_behaves_like "it does not conform"
  end
end
