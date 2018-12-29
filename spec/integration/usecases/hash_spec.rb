# frozen_string_literal: true

require "spec_helper"

describe "Hash validation" do
  subject(:definition) do
    definition
  end

  context "when keys are defined as symbols" do
    let(:definition) do
      Definition.Keys do
        required :first_name, Definition.Type(String)
      end
    end

    it_behaves_like "it conforms", first_name: "John"

    context "with string keys" do
      let(:value) { { "first_name" => "John" } }

      it_behaves_like "it does not conform"
    end
  end

  context "when keys are defined as strings" do
    let(:definition) do
      Definition.Keys do
        required "first_name", Definition.Type(String)
      end
    end

    it_behaves_like "it conforms", "first_name" => "John"

    context "with symbol keys" do
      let(:value) { { first_name: "John" } }

      it_behaves_like "it does not conform"
    end
  end
end
