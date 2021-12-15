# frozen_string_literal: true

require "spec_helper"

describe "Definition.LessThan" do
  subject(:definition) do
    Definition.LessThan(5)
  end

  it_behaves_like "it conforms", 4
  it_behaves_like "it conforms", 4.9

  context "with too big value" do
    let(:value) { 5 }

    it_behaves_like "it does not conform"
  end

  context "with deprecated interface that had a typo" do
    subject(:definition) do
      Definition.LessThen(5)
    end

    it_behaves_like "it conforms", 4
  end
end
