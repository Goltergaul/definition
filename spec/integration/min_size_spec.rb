# frozen_string_literal: true

require "spec_helper"

describe "Definition.MinSize" do
  subject(:definition) do
    Definition.MinSize(5)
  end

  it_behaves_like "it conforms", "a" * 5
  it_behaves_like "it conforms", "a" * 6
  it_behaves_like "it conforms", [12, 4, 5, 2, 4]
  it_behaves_like "it conforms", [12, 4, 5, 2, 4, 6]

  context "with too short string value" do
    let(:value) { "a" * 4 }

    it_behaves_like "it does not conform"
  end

  context "with too short array value" do
    let(:value) { [1, 2, 3, 4] }

    it_behaves_like "it does not conform"
  end
end
