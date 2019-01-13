# frozen_string_literal: true

require "spec_helper"

describe "Definition.Regex" do
  subject(:definition) do
    Definition.Regex(/^\d*$/)
  end

  it_behaves_like "it conforms", "123"

  context "with a non digit value" do
    let(:value) { "abc2" }

    it_behaves_like "it does not conform"
  end
end
