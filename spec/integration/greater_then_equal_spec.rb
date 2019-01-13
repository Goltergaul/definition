# frozen_string_literal: true

require "spec_helper"

describe "Definition.GreaterThenEqual" do
  subject(:definition) do
    Definition.GreaterThenEqual(5)
  end

  it_behaves_like "it conforms", 5
  it_behaves_like "it conforms", 5.1

  context "with too small value" do
    let(:value) { 4.9 }

    it_behaves_like "it does not conform"
  end
end
