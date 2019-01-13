# frozen_string_literal: true

require "spec_helper"

describe "Definition.NonEmptyString" do
  subject(:definition) do
    Definition.NonEmptyString
  end

  it_behaves_like "it conforms", "a"

  context "with empty string" do
    let(:value) { "" }

    it_behaves_like "it does not conform"
  end

  context "with other type" do
    let(:value) { [1] }

    it_behaves_like "it does not conform"
  end
end
