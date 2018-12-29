# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Each do
  describe ".conform" do
    describe "without coersion" do
      context "with three values where the first and last one are not valid" do
        it "does not conform" do
          definition = double(:definition)
          expect(definition).to receive(:conform)
            .with("b")
            .and_return(Definition::ConformResult.new("b", errors: [
              double(:conform_error, message: "Is not of type Integer")
            ]))
            .ordered
          expect(definition).to receive(:conform)
            .with(1)
            .and_return(Definition::ConformResult.new(1))
            .ordered
          expect(definition).to receive(:conform)
            .with("4")
            .and_return(Definition::ConformResult.new("4", errors: [
              double(:conform_error, message: "Is not of type Integer")
            ]))
            .ordered

          result = described_class.new("each_test", definition: definition).conform(["b", 1, "4"])
          expect(result).to not_conform_with('Not all items conform with each_test: { Item "b" '\
                                             'did not conform to each_test: { Is not of type Integer '\
                                             '}, Item "4" did not conform to each_test: { Is not '\
                                             'of type Integer } }')
        end
      end

      context "with two values that are valid" do
        it "conforms" do
          definition = double(:definition)
          expect(definition).to receive(:conform)
            .and_return(Definition::ConformResult.new(1),
                        Definition::ConformResult.new(2))

          result = described_class.new("each_test", definition: definition).conform([1, 2])
          expect(result).to conform_with([1,2])
        end
      end

      context "with a non-array value" do
        it "does not conform" do
          definition = double(:definition)
          result = described_class.new("each_test", definition: definition).conform(1)
          expect(result).to not_conform_with('Non-Array value does not conform with each_test')
        end
      end
    end

    describe "with coersion" do
      context "with two values that are valid and coerced" do
        it "conforms" do
          definition = double(:definition)
          expect(definition).to receive(:conform)
            .and_return(Definition::ConformResult.new(1),
                        Definition::ConformResult.new(2))

          result = described_class.new("each_test", definition: definition).conform(["1", "2"])
          expect(result).to conform_with([1,2])
        end
      end
    end
  end
end
