# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Each do
  describe ".conform" do
    subject(:result) { each.conform(value) }

    let(:each) do
      described_class.new("each", definition: definition)
    end
    let(:definition) do
      Definition.Type(Integer)
    end

    describe "without coersion" do
      context "with three values where the first and last one are not valid" do
        let(:value) { ["b", 1, "4"] }

        it "does not conform" do
          expect(result).to not_conform_with('Not all items conform with \'each\': { Item "b" did not conform'\
            ' to each: { Is of type String instead of Integer }, Item "4" did not conform to each: { Is of'\
            " type String instead of Integer } }")
        end

        it "produces a good translated error message" do
          expect(result.errors.map(&:translated_error)).to eql(
            ["Value is of wrong type, needs to be a Integer", "Value is of wrong type, needs to be a Integer"]
          )
        end
      end

      context "with two values that are valid" do
        it "conforms" do
          definition = instance_double(Definition::Types::Base)
          expect(definition).to receive(:conform)
            .and_return(Definition::ConformResult.new(1),
                        Definition::ConformResult.new(2))

          result = described_class.new("each_test", definition: definition).conform([1, 2])
          expect(result).to conform_with([1, 2])
        end
      end

      context "with a non-array value" do
        let(:value) { 1 }

        it "does not conform" do
          expect(result).to not_conform_with("Non-Array value does not conform with each")
        end

        it "produces a good translated error message" do
          expect(result.errors.map(&:translated_error)).to eql(
            ["Is not an Array"]
          )
        end
      end
    end

    describe "with coersion" do
      context "with two values that are valid and coerced" do
        let(:value) { %w[1 2] }
        let(:definition) do
          Definition.CoercibleType(Integer)
        end

        it "conforms" do
          expect(result).to conform_with([1, 2])
        end
      end
    end
  end
end
