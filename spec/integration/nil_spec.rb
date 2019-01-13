# frozen_string_literal: true

require "spec_helper"

describe "Definition.Nil" do
  subject(:definition) do
    Definition.Nil
  end

  it_behaves_like "it conforms", nil

  context "with string value" do
    let(:value) { "a" }

    it_behaves_like "it does not conform"
  end
end
