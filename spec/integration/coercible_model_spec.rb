# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

describe "Definition.CoercibleModel" do
  let(:test_model_class) do
    AddressModelClass = address_model_class
    Class.new(Definition::Model) do
      required :username, Definition.Type(String)
      required :address, Definition.CoercibleModel(AddressModelClass)
    end
  end

  let(:address_model_class) do
    Class.new(Definition::Model) do
      required :street, Definition.Type(String)
      required :postal_code, Definition.Type(String)
    end
  end

  it "intantiates correctly when address is a plain hash" do
    value = { username: "John", address: { street: "Fakestr", postal_code: "2222" } }
    model_instance = test_model_class.new(value)

    expect(model_instance.address).to eq(address_model_class.new(street: "Fakestr", postal_code: "2222"))
    expect(model_instance.address).to be_a(address_model_class)
    expect(model_instance.username).to eq("John")
  end

  it "instantiates correctly when address is a Address instance" do
    address = address_model_class.new(street: "Fakestr", postal_code: "2222")
    model_instance = test_model_class.new(username: "John", address: address)

    expect(model_instance.address).to eq(address)
    expect(model_instance.address).to be_a(address_model_class)
    expect(model_instance.username).to eq("John")
  end
end
