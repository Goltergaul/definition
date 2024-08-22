# frozen_string_literal: true

require "spec_helper"

describe Definition::Types::Keys do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    context "with option ignore_extra_keys" do
      let(:definition) do
        described_class.new("address",
                            opt:     {
                              favorite_color: Definition.Type(String)
                            },
                            options: {
                              ignore_extra_keys: true
                            })
      end

      context "with extra key in input hash" do
        let(:value) { { favorite_color: "blue", foobar: 1 } }

        it "does conform" do
          expect(conform).to conform_with(favorite_color: "blue")
        end
      end
    end

    context "with default values" do
      let(:definition) do
        described_class.new("address",
                            opt:      {
                              favorite_color: Definition.Type(String),
                              favorite_drink: Definition.Type(String)
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
        let(:value) { { favorite_color: "blue", favorite_drink: "juice" } }

        it "does conform" do
          expect(conform).to conform_with(favorite_color: "blue",
                                          favorite_drink: "juice")
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
        Definition.Type(String)
      end
      let(:int_def) do
        Definition.Type(Integer)
      end
      let(:include_def) do
        Definition.Enum(*required_keys.keys)
      end

      context "with missing req and missing opt field" do
        let(:value) { {} }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address is missing key :street, address is missing key :city"
          )
        end

        it "produces a good translated error message" do
          expect(conform.errors.map(&:translated_error)).to eql(
            ["Is missing", "Is missing"]
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

        it "produces a good translated error message" do
          expect(conform.errors.map(&:translated_error)).to eql(
            ["Is missing", "Is missing", "Value is of wrong type, needs to be a Integer"]
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

        it "produces a good translated error message" do
          expect(conform.errors.map(&:translated_error)).to eql(
            ["Is unexpected"]
          )
        end
      end

      context "when the input value is nil" do
        let(:value) { nil }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address is not a Hash"
          )
        end

        it "produces a good translated error message" do
          expect(conform.errors.map(&:translated_error)).to eql(
            ["Is not a Hash"]
          )
        end
      end

      context "when the input value is an Integer" do
        let(:value) { 12 }

        it "does not conform" do
          expect(conform).to not_conform_with(
            "address is not a Hash"
          )
        end
      end
    end
  end

  describe ".dup" do
    it "dups definitions and defaults" do
      original = described_class.new("person",
                                     req:      {
                                       name: Definition.Type(String)
                                     },
                                     opt:      {
                                       age:        Definition.Type(Integer),
                                       authorized: Definition.Boolean
                                     },
                                     defaults: {
                                       authorized: false
                                     })
      copy = original.dup

      original.required_definitions.clear
      original.optional_definitions.clear
      original.defaults.clear

      value = {
        name: "John",
        age:  18
      }
      expected = {
        name:       "John",
        age:        18,
        authorized: false
      }
      expect(copy.conform(value)).to conform_with(expected)
    end
  end
end
