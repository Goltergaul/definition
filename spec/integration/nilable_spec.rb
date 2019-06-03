# frozen_string_literal: true

require "spec_helper"

describe "Definition.Nilable" do
  subject(:definition) do
    Definition.Nilable(Definition.Type(String))
  end

  it_behaves_like "it conforms", nil
  it_behaves_like "it conforms", "foo"

  context "with float value" do
    let(:value) { 2.0 }

    it_behaves_like "it does not conform"
  end
end
