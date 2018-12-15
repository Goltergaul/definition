# frozen_string_literal: true

require "spec_helper"
require "definition/types/lambda"

describe Definition::Types::Lambda do
  let(:definition) do
    described_class.new(:lambda_test,
                        test_lambda)
  end
  let(:test_lambda) { ->(value) { value.even? } }

  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    context "with even value" do
      let(:value) { 2 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with odd value" do
      let(:value) { 1 }

      it "does not conform" do
        expect(conform).to not_conform_with(
          "Did not pass test for lambda_test"
        )
      end
    end
  end
end
