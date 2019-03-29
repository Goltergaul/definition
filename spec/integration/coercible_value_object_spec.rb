# frozen_string_literal: true

require "spec_helper"
require "bigdecimal"

describe "Definition.Boolean" do
  class TestIntegerArray < Definition::ValueObject
    definition(Definition.Each(Definition.Type(Integer)))
  end

  class TestUser < Definition::ValueObject
    definition(Definition.Keys do
      required :username, Definition.Type(String)
      required :scores, Definition.CoercibleValueObject(TestIntegerArray)
    end)
  end

  it "intantiates correctly when scores is an integer array" do
    value = { username: "John", scores: [1, 2, 3] }
    value_object = TestUser.new(value)

    expect(value_object.scores).to eq([1, 2, 3])
    expect(value_object.scores).to be_a(TestIntegerArray)
  end

  it "instantiates correctly when scores is a TestIntegerArray instance" do
    value = { username: "John", scores: TestIntegerArray.new([1, 2, 3]) }
    value_object = TestUser.new(value)

    expect(value_object.scores).to eq([1, 2, 3])
    expect(value_object.scores).to be_a(TestIntegerArray)
  end
end
