# frozen_string_literal: true

require "spec_helper"

describe "Definition.Empty" do
  subject(:definition) do
    Definition.Empty
  end

  it_behaves_like "it conforms", []
  it_behaves_like "it conforms", {}
  it_behaves_like "it conforms", ""

  context "with a non empty string value" do
    let(:value) { "a" }

    it_behaves_like "it does not conform"
  end

  context "with a non empty array value" do
    let(:value) { ["a"] }

    it_behaves_like "it does not conform"
  end

  context "with a non empty hash value" do
    let(:value) { { a: 1 } }

    it_behaves_like "it does not conform"
  end
end
