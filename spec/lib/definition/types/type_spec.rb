# frozen_string_literal: true

require "spec_helper"
require "definition/types/type"

describe Definition::Types::Type do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    let(:definition) do
      described_class.new(:type_test,
                          ::Integer,
                          coerce: coerce)
    end
    let(:coerce) { false }

    context "with int value" do
      let(:value) { 2 }
      it { is_expected.to conform_with(value) }
    end

    context "with string value" do
      let(:value) { "2" }
      let(:expected_errors) do
        [
          {
            value:       value,
            name:        :type_test,
            description: "is_a? Integer",
            definition:  definition,
            children:    []
          }
        ]
      end

      it "generates correct errors" do
        expect(conform).to not_conform_with(expected_errors)
      end
    end

    context "with coercion lambda" do
      let(:coerce) do
        lambda do |v|
          begin
                       Integer(v)
                     rescue
                       v
                     end
        end
      end

      context "with coercable value" do
        let(:value) { "2" }
        it { is_expected.to conform_with(2) }
      end

      context "with uncoercable value" do
        let(:value) { "a2" }
        let(:expected_errors) do
          [
            {
              value:       value,
              name:        :type_test,
              description: "is_a? Integer",
              definition:  definition,
              children:    []
            }
          ]
        end
        it { is_expected.to not_conform_with(expected_errors) }
      end
    end
  end
end
