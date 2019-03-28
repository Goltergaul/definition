# frozen_string_literal: true

require "spec_helper"

describe "ValueObject" do
  let(:test_value_object) do
    class TestValueObject < Definition::ValueObject
      definition(Definition.Keys do
        required :name, Definition.Type(String)
      end)
    end
    TestValueObject
  end

  it "can be instantiated with valid input" do
    expect(test_value_object.new(name: "John").name).to eql("John")
  end

  it "throws error with invalid input" do
    expect do
      test_value_object.new(age: 18)
    end.to raise_error(Definition::InvalidValueObjectError, /age/)
  end

  context "with nested value objects" do
    let(:test_value_object) do
      foo_value_object
      class TestValueObject2 < Definition::ValueObject
        definition(Definition.Keys do
          required :foo, Definition.CoercibleValueObject(FooValueObject)
        end)
      end
      TestValueObject2
    end
    let(:foo_value_object) do
      class FooValueObject < Definition::ValueObject
        definition(Definition.Keys do
          required :bar, Definition.Type(String)
        end)
      end
      FooValueObject
    end

    it "can be instantiated with valid input" do
      foo_object = foo_value_object.new(bar: "test")
      expect(test_value_object.new(foo: foo_object).foo).to eql(foo_object)
    end

    it "can be instantiated with foo being a hash via coercion" do
      foo_object = foo_value_object.new(bar: "test")

      value_object = test_value_object.new(foo: { bar: "test" })
      expect(value_object.foo).to eql(foo_object)
      expect(value_object.foo.bar).to eq("test")
    end

    it "throws error with invalid input" do
      expect do
        test_value_object.new(foo: { bar: 2.0 })
      end.to raise_error(Definition::InvalidValueObjectError, /bar/)
    end

    it "correctly nests the error hash" do
      begin
        test_value_object.new(foo: { bar: 2.0 })
      rescue Definition::InvalidValueObjectError => e
        verify(format: :json) { e.conform_result.error_hash }
      end
    end
  end
end
