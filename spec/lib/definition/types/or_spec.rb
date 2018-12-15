# frozen_string_literal: true

require "spec_helper"
require "definition/types/or"
require "definition/types/lambda"

describe Definition::Types::Or do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }
    let(:definition) do
      described_class.new("or_test",
                          definition1,
                          definition2)
    end
    let(:definition1) do
      Definition::Types::Lambda.new(:def1, lambda do |v|
        v > 5 || v.even?
      end)
    end
    let(:definition2) do
      Definition::Types::Lambda.new(:def2, lambda do |v|
        v > 10
      end)
    end

    context "with value that fails all definitions" do
      let(:value) { 1 }

      it "does not conform" do
        expect(conform).to not_conform_with(
          "None of the children are valid for or_test: { Did not pass test for def1, Did not pass test for def2 }"
        )
      end
    end

    context "with value that fails only def2 definition" do
      let(:value) { 6 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with value that fails only def1 definition" do
      let(:value) { 11 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with value that fails no definition" do
      let(:value) { 12 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end
  end
end
