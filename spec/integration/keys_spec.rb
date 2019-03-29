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
      optional :receive_newsletter, Definition.Boolean, default: false
    end
  end

  it_behaves_like "it conforms via coersion",
                  input:  {
                    first_name: "Jon",
                    last_name:  "Doe",
                    address:    {
                      street:   "123 Fakestreet",
                      zip_code: 12_345
                    }
                  },
                  output: {
                    first_name:         "Jon",
                    last_name:          "Doe",
                    address:            {
                      street:   "123 Fakestreet",
                      zip_code: 12_345
                    },
                    receive_newsletter: false
                  }

  context "with unexpected key in input hash" do
    subject(:definition) do
      Definition.Keys do
        required :first_name, Definition.Type(String)
      end
    end

    let(:value) do
      {
        first_name:     "Jon",
        unexpected_key: "foobar"
      }
    end

    it_behaves_like "it does not conform"
  end

  context "with unexpected key in input hash and option to ignore unexpected key set to true" do
    subject(:definition) do
      Definition.Keys do
        option :ignore_extra_keys
        required :first_name, Definition.Type(String)
      end
    end

    it_behaves_like "it conforms via coersion",
                    input:  {
                      first_name:     "Jon",
                      unexpected_key: "foobar"
                    },
                    output: {
                      first_name: "Jon"
                    }
  end
end
