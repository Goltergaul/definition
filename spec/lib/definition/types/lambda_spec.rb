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
      it { is_expected.to conform_with(value) }
    end

    context "with odd value" do
      let(:value) { 1 }
      let(:expected_errors) do
        [
          {
            value:       value,
            name:        :lambda_test,
            description: "lambda?",
            definition:  definition,
            children:    []
          }
        ]
      end

      it "generates correct errors" do
        expect(conform).to not_conform_with(expected_errors)
      end

      it_behaves_like "it explains"
    end
  end
end
