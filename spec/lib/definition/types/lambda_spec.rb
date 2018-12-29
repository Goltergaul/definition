# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Lambda do
  let(:definition) do
    described_class.new(:lambda_test,
                        &test_lambda)
  end

  describe "when definition does not coerce" do
    let(:test_lambda) { ->(value) { conform_with(value) if value.even? } }

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

  describe "when definition does coerce" do
    let(:test_lambda) do
      lambda do |value|
        begin
          conform_with(Float(value))
        rescue ArgumentError
          value
        end
      end
    end

    describe ".conform" do
      subject(:conform) { definition.conform(value) }

      context "with coercable value" do
        let(:value) { "2.3" }

        it "conforms" do
          expect(conform).to conform_with(2.3)
        end
      end

      context "with uncoercable value" do
        let(:value) { "foobar" }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "Did not pass test for lambda_test"
          )
        end
      end
    end
  end
end
