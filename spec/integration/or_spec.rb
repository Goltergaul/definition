# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

describe "Definition.Or" do
  subject(:definition) do
    Definition.Or(def1, def2)
  end

  let(:def1) { Definition::Type(Float) }
  let(:def2) { Definition::Lambda(:foo) { |value| conform_with(value) if value > 1.0 } }

  it_behaves_like "it conforms", 9.99
  it_behaves_like "it conforms", 2
  it_behaves_like "it conforms", 0.0

  context "with integer less then 1.0" do
    let(:value) { BigDecimal("0") }

    it_behaves_like "it does not conform"
  end
end
