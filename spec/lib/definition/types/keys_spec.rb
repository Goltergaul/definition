# frozen_string_literal: true

require "spec_helper"
require "definition/types/keys"
require "definition/types/lambda"

describe Definition::Types::Keys do
  describe ".conform" do
    subject(:conform) { definition.conform(value) }

    context "with required params" do
      let(:definition) do
        described_class.new("address",
                            req: {
                              street: string_def,
                              city: string_def
                            },
                            opt: {
                              appartment_number: int_def
                            })
      end
      let(:string_def) do
        Definition::Types::Type.new(:string, String)
      end
      let(:int_def) do
        Definition::Types::Type.new(:integer, Integer)
      end
      let(:include_def) { definition.instance_variable_get("@required_definition") }

      context "with missing req and missing opt field" do
        let(:value) { {} }

        it "has correct errors" do
          expect(conform).to not_conform_with([
            {
              value: value,
              name: "address",
              description: "keys? req: [street city] opt: [appartment_number]",
              definition: definition,
              children: [
                {
                  value: value,
                  name: "address",
                  description: "include? :street",
                  definition: include_def,
                  children: []
                },
                {
                  value: value,
                  name: "address",
                  description: "include? :city",
                  definition: include_def,
                  children: []
                }
              ]
            }
          ])
        end
      end

      context "with missing req and invalid opt field" do
        let(:value) { { appartment_number: "12" } }

        it "has correct errors" do
          expect(conform).to not_conform_with([
            {
              value: value,
              name: "address",
              description: "keys? req: [street city] opt: [appartment_number]",
              definition: definition,
              children: [
                {
                  value: value,
                  name: "address",
                  description: "include? :street",
                  definition: include_def,
                  children: []
                },
                {
                  value: value,
                  name: "address",
                  description: "include? :city",
                  definition: include_def,
                  children: []
                },
                {
                  value: value,
                  name: "appartment_number",
                  description: "key appartment_number",
                  definition: definition,
                  children: [
                    {
                      value: "12",
                      name: "integer",
                      description: "is_a? Integer",
                      definition: int_def,
                      children: []
                    }
                  ]
                }
              ]
            }
          ])
        end
      end

      context "with missing req and valid opt field" do
        let(:value) { { appartment_number: 12 } }

        it "has correct errors" do
          expect(conform).to not_conform_with([
            {
              value: value,
              name: "address",
              description: "keys? req: [street city] opt: [appartment_number]",
              definition: definition,
              children: [
                {
                  value: value,
                  name: "address",
                  description: "include? :street",
                  definition: include_def,
                  children: []
                },
                {
                  value: value,
                  name: "address",
                  description: "include? :city",
                  definition: include_def,
                  children: []
                }
              ]
            }
          ])
        end
      end

      context "with all req fields valid and valid opt field" do
        let(:value) do
          {
            street: "fakestr 123",
            appartment_number: 12,
            city: "London"
          }
        end

        it "conforms" do
          expect(conform).to conform_with(value)
        end
      end

      context "with unexpected field" do
        let(:value) do
          {
            street: "fakestr 123",
            appartment_number: 12,
            city: "London",
            foo: "bar"
          }
        end

        it "fails with correct error" do
          expect(conform).to not_conform_with([
            {
              value: value,
              name: "address",
              description: "keys? req: [street city] opt: [appartment_number]",
              definition: definition,
              children: [
                {
                  value: value,
                  name: "address",
                  description: "unexpected keys: [foo]",
                  definition: definition,
                  children: []
                }
              ]
            }
          ])
        end
      end
    end
  end
end
