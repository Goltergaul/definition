# frozen_string_literal: true

require "spec_helper"
require "definition/types/and"
require "definition/types/lambda"

describe Definition::Types::And do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }
    let(:definition) do
      described_class.new("and_test",
                          definition1,
                          definition2)
    end
    let(:definition1) do
      Definition::Types::Lambda.new(:def1, lambda do |v|
        v > 5
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
          "Not all children are valid for and_test: { Did not pass test for def1, Did not pass test for def2 }"
        )
      end
    end

    context "with value that fails one definition" do
      let(:value) { 6 }

      it "does not conform" do
        expect(conform).to not_conform_with(
          "Not all children are valid for and_test: { Did not pass test for def2 }"
        )
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
