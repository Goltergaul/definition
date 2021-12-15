# frozen_string_literal: true

require "spec_helper"

describe "Definition.LessThanEqual" do
  subject(:definition) do
    Definition.LessThanEqual(5)
  end

  it_behaves_like "it conforms", 5
  it_behaves_like "it conforms", 4.9

  context "with too big value" do
    let(:value) { 5.1 }

    it_behaves_like "it does not conform"
  end

  context "with deprecated interface that had a typo" do
    subject(:definition) do
      Definition.LessThenEqual(5)
    end

    it_behaves_like "it conforms", 5
  end
end
