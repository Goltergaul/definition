# frozen_string_literal: true

require "spec_helper"

describe "Definition.Keys" do
  subject(:definition) do
    Definition.Keys do
      required(:foobar, Definition.Keys do
        required :name, Definition.And(
          Definition.Type(String),
          Definition.Regex(/^\D+$/)
        )
        required(:colors, Definition.Each(
                            Definition.And(
                              Definition.Type(String),
                              Definition.NonEmpty
                            )
                          ))
      end)
      required :someBoolean,
               Definition.Or(
                 Definition.Type(TrueClass), Definition.Type(FalseClass)
               )
    end
  end

  context "with multiple errors" do
    let(:value) do
      {
        foobar:      {
          name:   "Alice89",
          colors: [
            "red",
            "green",
            "",
            2.0,
            "yellow"
          ]
        },
        someBoolean: "true"
      }
    end

    it_behaves_like "it does not conform"
  end
end
