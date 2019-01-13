# frozen_string_literal: true

require "spec_helper"

describe "Definition.NonEmpty" do
  subject(:definition) do
    Definition.NonEmpty
  end

  it_behaves_like "it conforms", ["a"]
  it_behaves_like "it conforms", a: 1
  it_behaves_like "it conforms", "a"

  context "with a empty string value" do
    let(:value) { "" }

    it_behaves_like "it does not conform"
  end

  context "with a empty array value" do
    let(:value) { [] }

    it_behaves_like "it does not conform"
  end

  context "with a empty hash value" do
    let(:value) { {} }

    it_behaves_like "it does not conform"
  end
end
