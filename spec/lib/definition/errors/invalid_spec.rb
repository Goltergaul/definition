# frozen_string_literal: true

require "spec_helper"
require "definition/errors/invalid"
require "ostruct"

describe Definition::Errors::Invalid do
  subject(:instance) do
    described_class.new(value,
                        name:        name,
                        description: description,
                        definition:  definition,
                        children:    children)
  end

  describe ".message" do
    subject(:message) { instance.message }
    let(:name) { "person" }
    let(:description) { "" }
    let(:definition) do
      OpenStruct.new(name: "person")
    end
    let(:age_definition) do
      OpenStruct.new(name: "age")
    end
    let(:permissions_definition) do
      OpenStruct.new(name: "permissions")
    end
    let(:boolean_definition) do
      OpenStruct.new(name: "boolean")
    end
    let(:value) do
      {
        permissions: {
          access_mainframe: "false"
        },
        age:         "13"
      }
    end

    context "with nested errors" do
      let(:children) do
        [
          described_class.new({ access_mainframe: "false" },
                              name:        :permissions,
                              description: "include? access_mainframe",
                              definition:  permissions_definition,
                              children:    [

                                described_class.new("false",
                                                    name:        :access_mainframe,
                                                    description: "boolean?",
                                                    definition:  boolean_definition,
                                                    children:    [])
                              ]),
          described_class.new("13",
                              name:        :age,
                              description: "integer?",
                              definition:  age_definition,
                              children:    [])
        ]
      end

      it { verify { message } }
    end
  end
end
