# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Keys do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    context "with default values" do
      let(:definition) do
        described_class.new("address",
                            opt:      {
                              favorite_color: Definition.Type(String),
                              favorite_food:  Definition.Type(String)
                            },
                            defaults: {
                              favorite_color: "red",
                              favorite_drink: "cola"
                            })
      end

      context "with empty hash input" do
        let(:value) { {} }

        it "does conform" do
          expect(conform).to conform_with(favorite_color: "red", favorite_drink: "cola")
        end
      end

      context "with favorite color and food" do
        let(:value) { { favorite_color: "blue", favorite_food: "apple" } }

        it "does conform" do
          expect(conform).to conform_with(favorite_color: "blue",
                                          favorite_drink: "cola",
                                          favorite_food:  "apple")
        end
      end
    end

    context "with required params" do
      let(:definition) do
        described_class.new("address",
                            req: required_keys,
                            opt: {
                              appartment_number: int_def
                            })
      end
      let(:required_keys) do
        {
          street: string_def,
          city:   string_def
        }
      end
      let(:string_def) do
        Definition::Types::Type.new(:string, String)
      end
      let(:int_def) do
        Definition::Types::Type.new(:integer, Integer)
      end
      let(:include_def) do
        Definition::Types::Include.new(definition.name, *required_keys.keys)
      end

      before do
        allow(Definition::Types::Include).to receive(:new)
          .with(definition.name, *required_keys.keys)
          .and_return(include_def)
      end

      context "with missing req and missing opt field" do
        let(:value) { {} }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address is missing key :street, address is missing key :city"
          )
        end
      end

      context "with missing req and invalid opt field" do
        let(:value) { { appartment_number: "12" } }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address is missing key :street, "\
            "address is missing key :city, "\
            "address fails validation for key appartment_number: { Is of type String instead of Integer }"
          )
        end
      end

      context "with missing req and valid opt field" do
        let(:value) { { appartment_number: 12 } }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address is missing key :street, address is missing key :city"
          )
        end
      end

      context "with all req fields valid and valid opt field" do
        let(:value) do
          {
            street:            "fakestr 123",
            appartment_number: 12,
            city:              "London"
          }
        end

        it "conforms" do
          expect(conform).to conform_with(value)
        end
      end

      context "with unexpected field" do
        let(:value) do
          {
            street:            "fakestr 123",
            appartment_number: 12,
            city:              "London",
            foo:               "bar"
          }
        end

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address has extra key: :foo"
          )
        end
      end
    end
  end
end
