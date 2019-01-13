# frozen_string_literal: true

require "spec_helper"

describe "Definition.Equal" do
  subject(:definition) do
    Definition.Equal("foobar")
  end

  it_behaves_like "it conforms", "foobar"

  context "with another string value" do
    let(:value) { "a" }

    it_behaves_like "it does not conform"
  end
end
