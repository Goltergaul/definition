# frozen_string_literal: true

require "spec_helper"

describe Definition::ValueObject do
  let(:frozen_error) do
    defined?(FrozenError) ? FrozenError : RuntimeError
  end

  describe "with a class that has no definition defined" do
    class TestUnconfiguredValueObject < described_class; end

    it "raises error when no definition is configured" do
      expect { TestUnconfiguredValueObject.new({}) }.to raise_error(Definition::NotConfiguredError)
    end
  end

  describe "with an array as value for the value object" do
    class TestArrayValueObject < described_class
      definition(Definition.Each(Definition.Type(Integer)))
    end

    it "can be instantiated with an array value and behaves as array" do
      vo = TestArrayValueObject.new([1, 2, 3])
      expect(vo).to contain_exactly(1, 2, 3)
      expect(vo).to eq([1, 2, 3])
      expect(vo.first).to eq(1)
    end

    it "cannot be modified" do
      vo = TestArrayValueObject.new([1, 2, 3])

      expect { vo[0] = 2 }.to raise_error(frozen_error)
    end
  end

  describe "with a hash as value for the value object" do
    class TestKeysValueObject < described_class
      definition(Definition.Keys do
        optional :first_name, Definition.Type(String)
        required :last_name,  Definition.Type(String)
      end)
    end

    it "can be instantiated with keyword arguments" do
      vo = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")
      expect(vo.first_name).to eql("Jon")
      expect(vo.last_name).to eql("Doe")
    end

    it "can be instantiated with one hash argument" do
      vo = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")
      expect(vo.first_name).to eql("Jon")
      expect(vo.last_name).to eql("Doe")
    end

    it "cannot be modified via setters" do
      vo = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")

      expect { vo.first_name = "Anna" }.to raise_error(NoMethodError)
    end

    it "cannot be modified via the underlying hash" do
      vo = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")

      expect { vo[:first_name] = "Anna" }.to raise_error(frozen_error)
    end

    it "raises error when data does not conform to the value object definition" do
      expect do
        TestKeysValueObject.new(first_name: "Jon", last_name: 1)
      end.to raise_error(Definition::InvalidValueObjectError, /last_name/)
    end

    it "defines to_h" do
      vo = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")
      expect(vo.to_h).to eq(first_name: "Jon", last_name: "Doe")
    end

    it "can be compared" do
      vo1 = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")
      vo2 = TestKeysValueObject.new(first_name: "Jon", last_name: "Doe")
      vo3 = TestKeysValueObject.new(first_name: "Ed", last_name: "Example")

      expect(vo1).to eq(vo2)
      expect(vo2).not_to eq(vo3)
    end
  end
end
