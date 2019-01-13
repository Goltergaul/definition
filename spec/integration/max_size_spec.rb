# frozen_string_literal: true

require "spec_helper"

describe "Definition.MaxSize" do
  subject(:definition) do
    Definition.MaxSize(5)
  end

  it_behaves_like "it conforms", "a" * 5
  it_behaves_like "it conforms", "a"
  it_behaves_like "it conforms", [12, 4, 5, 2, 4]

  context "with too long string value" do
    let(:value) { "a" * 6 }

    it_behaves_like "it does not conform"
  end

  context "with too long array value" do
    let(:value) { [1, 2, 3, 4, 5, 6] }

    it_behaves_like "it does not conform"
  end
end
