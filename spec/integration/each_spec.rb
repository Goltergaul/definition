# frozen_string_literal: true

require "spec_helper"

describe "Definition.Each" do
  subject(:definition) do
    Definition.Each(Definition::Type(Integer))
  end

  it_behaves_like "it conforms", [1, 345, -4]

  context "with float value" do
    let(:value) { [1, -2, 1.0, "foo", 5] }

    it_behaves_like "it does not conform"
  end

  context "with hash value" do
    let(:value) { { a: 1 } }

    it_behaves_like "it does not conform"
  end

  context "with range value" do
    let(:value) { (1..2) }

    it_behaves_like "it does not conform"
  end

  context "with nested each definitions" do
    subject(:definition) do
      Definition.Each(Definition.Each(Definition::Type(Integer)))
    end

    context "with string value" do
      let(:value) { ["a"] }

      it_behaves_like "it does not conform"

      it "renders a good translated error message" do
        expect(definition.conform(value).errors.map(&:translated_error)).to eql(["Is not an Array"])
      end
    end
  end
end
