# frozen_string_literal: true

require "spec_helper"

describe "Definition.Keys" do
  subject(:definition) do
    Definition.Keys do
      required :first_name, Definition.Type(String)
      required :last_name, Definition.Type(String)
      required(:address, Definition.Keys do
        required :street, Definition.Type(String)
        required(:zip_code, Definition.Lambda(:zip_code) do |value|
          conform_with(value) if value.to_s =~ /^\d\d\d\d\d$/
        end)
      end)
      optional :age, Definition.CoercibleType(Integer)
    end
  end

  it_behaves_like "it conforms",
                  first_name: "Jon",
                  last_name:  "Doe",
                  address:    {
                    street:   "123 Fakestreet",
                    zip_code: 12_345
                  }
end