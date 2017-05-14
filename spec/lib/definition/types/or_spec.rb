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

      it "contains correct errors" do
        expect(conform).to not_conform_with([
                                              {
                                                value:       value,
                                                name:        "or_test",
                                                description: "or: [def1 def2]",
                                                definition:  definition,
                                                children:    [
                                                  {
                                                    value:       value,
                                                    name:        :def1,
                                                    description: "lambda?",
                                                    definition:  definition1,
                                                    children:    []
                                                  },
                                                  {
                                                    value:       value,
                                                    name:        :def2,
                                                    description: "lambda?",
                                                    definition:  definition2,
                                                    children:    []
                                                  }
                                                ]
                                              }
                                            ])
      end
    end

    context "with value that fails one definition" do
      let(:value) { 6 }

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
