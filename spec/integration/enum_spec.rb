# frozen_string_literal: true

require "spec_helper"

describe "Definition.Enum" do
  subject(:definition) do
    Definition.Enum("blue", "red", "yellow")
  end

  it_behaves_like "it conforms", "blue"
  it_behaves_like "it conforms", "red"
  it_behaves_like "it conforms", "yellow"

  context "with other value" do
    let(:value) { "pink" }

    it_behaves_like "it does not conform"
  end
end
