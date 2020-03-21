# frozen_string_literal: true

require "spec_helper"

describe "Definition.Keys included in another Keys definition" do
  subject(:definition) do
    address_definition = Definition.Keys do
      required :street, Definition.Type(String)
      required :city, Definition.Type(String)
      optional :verified, Definition.Boolean, default: false
      optional :country, Definition.Type(String)
    end

    Definition.Keys do
      required :first_name, Definition.Type(String)
      optional :last_name, Definition.Type(String)

      include address_definition
    end
  end

  it_behaves_like "it conforms via coersion",
                  input:  {
                    first_name: "John",
                    last_name:  "Doe",
                    street:     "123 Fakestr.",
                    city:       "London"
                  },
                  output: {
                    first_name: "John",
                    last_name:  "Doe",
                    street:     "123 Fakestr.",
                    city:       "London",
                    verified:   false
                  }

  context "when the included definition contains keys that are already defined" do
    subject(:definition) do
      included_definition = Definition.Keys do
        required :field_1, Definition.Type(String)
        required :field_2, Definition.Type(String)
        required :field_4, Definition.Type(String)
      end

      Definition.Keys do
        required :field_1, Definition.Type(String)
        required :field_2, Definition.Type(String)
        required :field_3, Definition.Type(String)

        include included_definition
      end
    end

    it do
      expect { definition }.to raise_error(
        ArgumentError,
        "Included definition tries to redefine already defined fields: field_1, field_2"
      )
    end
  end
end
