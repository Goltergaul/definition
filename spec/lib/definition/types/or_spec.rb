# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Or do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    let(:definition) do
      described_class.new("or_test",
                          definition1,
                          definition2)
    end

    context "with value that fails all definitions" do
      let(:definition1) do
        failing_definition(:def1, translated_error_message: "def1 error")
      end
      let(:definition2) do
        failing_definition(:def2, translated_error_message: "def2 error")
      end
      let(:value) { 1 }

      it "does not conform" do
        expect(conform).to not_conform_with(
          "None of the definitions are valid for 'or_test'. " \
            "Errors for last tested definition:: { Did not pass test for def2 }"
        )
      end

      it "produces a good translated error message" do
        expect(conform.errors.map(&:translated_error)).to eql(
          ["def2 error"]
        )
      end
    end

    context "with value that fails only def2 definition" do
      let(:definition1) do
        conforming_definition
      end
      let(:definition2) do
        failing_definition(:def2, translated_error_message: "def2 error")
      end
      let(:value) { 6 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with value that fails only def1 definition" do
      let(:definition1) do
        failing_definition(:def1, translated_error_message: "def1 error")
      end
      let(:definition2) do
        conforming_definition
      end
      let(:value) { 11 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with value that fails def1 definition and def2 coerces" do
      let(:definition1) do
        failing_definition(:def1, translated_error_message: "def1 error")
      end
      let(:definition2) do
        conforming_definition(conform_with: coerced_value)
      end
      let(:value) { 11 }
      let(:coerced_value) { 22 }

      it "conforms" do
        expect(conform).to conform_with(coerced_value)
      end
    end

    context "with value that fails no definition" do
      let(:definition1) do
        conforming_definition
      end
      let(:definition2) do
        conforming_definition
      end
      let(:value) { 12 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with value that fails no definition but both coerce differently" do
      let(:definition1) do
        conforming_definition(conform_with: coerced_value1)
      end
      let(:definition2) do
        conforming_definition(conform_with: coerced_value2)
      end
      let(:value) { 12 }
      let(:coerced_value1) { 1 }
      let(:coerced_value2) { 2 }

      it "conforms with the result of the first definition that conforms" do
        expect(conform).to conform_with(coerced_value1)
      end
    end
  end
end
