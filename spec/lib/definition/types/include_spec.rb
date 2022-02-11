# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Include do
  subject(:definition) do
    described_class.new(name, *required_items)
  end

  let(:name) { "include" }
  let(:required_items) { %i[name color] }

  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    context "with one missing value" do
      let(:value) { [:color] }

      it "does not conform" do
        expect(conform).to not_conform_with("include does not include :name")
      end

      it "produces a good translated error message" do
        expect(conform.errors.map(&:translated_error)).to eql(
          ["Does not include :name"]
        )
      end
    end

    context "with correct value" do
      let(:value) { %i[name color] }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with correct value in different order" do
      let(:value) { %i[color name] }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with one value too much" do
      let(:value) { %i[color name foobar] }

      it "conforms" do
        expect(conform).to conform_with(value)
      end
    end

    context "with empty array value" do
      let(:value) { [] }

      it "does not conform" do
        expect(conform).to not_conform_with(
          "include does not include :name, include does not include :color"
        )
      end

      it "produces a good translated error message" do
        expect(conform.errors.map(&:translated_error)).to eql(
          ["Does not include :name", "Does not include :color"]
        )
      end
    end
  end
end
