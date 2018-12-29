# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

describe "Definition.And" do
  subject(:definition) do
    Definition.And(def1, def2)
  end

  let(:def1) { Definition::Type(Float) }
  let(:def2) { Definition::Lambda(:foo) { |value| conform_with(value) if value > 1.0 } }

  it_behaves_like "it conforms", 9.99

  context "with float less then 1.0" do
    let(:value) { 0.5 }

    it_behaves_like "it does not conform"
  end

  context "with integer" do
    let(:value) { BigDecimal("2") }

    it_behaves_like "it does not conform"
  end
end
