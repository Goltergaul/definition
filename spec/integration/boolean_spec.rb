# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

describe "Definition.Boolean" do
  subject(:definition) do
    Definition.Boolean
  end

  it_behaves_like "it conforms", true
  it_behaves_like "it conforms", false

  context "with string 'true'" do
    let(:value) { "true" }

    it_behaves_like "it does not conform"
  end
end
