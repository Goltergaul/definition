# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Type do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    let(:definition) do
      described_class.new(:type_test,
                          ::Integer)
    end
    let(:coerce) { false }

    context "with int value" do
      let(:value) { 2 }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with string value" do
      let(:value) { "2" }

      it "does not conform" do
        expect(conform).to not_conform_with(
          "Is of type String instead of Integer"
        )
      end
    end

    context "with coercion lambda" do
      let(:definition) do
        described_class.new(:type_test, ::Integer) do |v|
          begin
            Integer(v)
          rescue StandardError
            v
          end
        end
      end

      context "with coercable value" do
        let(:value) { "2" }

        it "conforms" do
          expect(conform).to conform_with(2)
        end
      end

      context "with uncoercable value" do
        let(:value) { "a2" }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "Is of type String instead of Integer"
          )
        end
      end
    end
  end
end
