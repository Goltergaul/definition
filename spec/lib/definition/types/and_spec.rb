# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::And do
  describe ".conform" do
    describe "without coersion" do
      subject(:conform) do
        described_class.new("and_test",
                            definition1,
                            definition2).conform(value)
      end

      context "with value that fails all definitions" do
        let(:definition1) do
          failing_definition(value, "Did not pass test for def1")
        end
        let(:definition2) do
          failing_definition(value, "Did not pass test for def2")
        end
        let(:value) { 1 }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "Not all definitions are valid for 'and_test': { Did not pass test for def1 }"
          )
        end
      end

      context "with value that fails one definition" do
        let(:definition1) do
          conforming_definition(value)
        end
        let(:definition2) do
          failing_definition(value, "Did not pass test for def2")
        end
        let(:value) { 6 }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "Not all definitions are valid for 'and_test': { Did not pass test for def2 }"
          )
        end
      end

      context "with value that fails no definition" do
        let(:definition1) do
          conforming_definition(value)
        end
        let(:definition2) do
          conforming_definition(value)
        end
        let(:value) { 12 }

        it "conforms" do
          expect(conform).to conform_with(value)
        end
      end
    end

    describe "with coersion" do
      subject(:definition) do
        described_class.new("and_test",
                            definition_int,
                            definition_float).conform("1.3")
      end

      let(:definition_int) do
        conforming_definition(1)
      end
      let(:definition_float) do
        conforming_definition(1.0)
      end

      it "conforms" do
        expect(definition).to conform_with(1.0)
      end
    end
  end
end
