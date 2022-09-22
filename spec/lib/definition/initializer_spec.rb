# frozen_string_literal: true

require "spec_helper"

describe Definition::Initializer do
  let(:test_class) do
    Class.new do
      include Definition::Initializer
    end
  end

  it "is initializable" do
    test_class.new
  end

  context "when required and optional keyword arguments are configured" do
    before do
      test_class.required(:arg1, Definition.Type(String))
      test_class.optional(:arg2, Definition.Type(String))
    end

    it "is initializable and exposes those arguments as private getters" do
      instance = test_class.new(arg1: "value1", arg2: "value2")

      expect(instance.send(:arg1)).to eq("value1")
      expect(instance.send(:arg2)).to eq("value2")
      expect { instance.public_send(:arg1) }.to raise_error(NoMethodError)
      expect { instance.public_send(:arg2) }.to raise_error(NoMethodError)
    end

    it "allows the attributes to get changed" do
      instance = test_class.new(arg1: "value1")
      expect(instance.send(:arg1)).to eq("value1")

      instance.send(:arg1=, "value2")
      expect(instance.send(:arg1)).to eq("value2")
    end

    it "is initializable without the optional argument" do
      instance = test_class.new(arg1: "value1")

      expect(instance.send(:arg1)).to eq("value1")
      expect(instance.send(:arg2)).to be nil
    end

    it "raises an error if the required argument is missing" do
      expect { test_class.new }.to raise_error(Definition::Initializer::InvalidArgumentError,
                                               /hash is missing key :arg1/)
    end

    it "raises an error if the required argument is not conforming its definition" do
      expect { test_class.new(arg1: 1) }.to raise_error(
        Definition::Initializer::InvalidArgumentError,
        /hash fails validation for key arg1: { Is of type Integer instead of String }/
      )
    end

    it "raises an error if the optional argument is not conforming its definition" do
      expect { test_class.new(arg1: "value1", arg2: 1) }.to raise_error(
        Definition::Initializer::InvalidArgumentError,
        /hash fails validation for key arg2: { Is of type Integer instead of String }/
      )
    end

    it "raises an error if both arguments are not conforming its definition" do
      expect { test_class.new(arg1: 1, arg2: 1) }.to raise_error(
        Definition::Initializer::InvalidArgumentError,
        /hash fails validation for key arg1: .*, hash fails validation for key arg2:/
      )
    end

    it "raises an error if an unexpected keyword is passed in" do
      expect { test_class.new(arg1: "value1", arg3: "value3") }.to raise_error(
        Definition::Initializer::InvalidArgumentError,
        /hash has extra key: :arg3/
      )
    end
  end

  context "when there is an optional argument with default" do
    before do
      test_class.optional(:arg1, Definition.Type(String), default: "default_value")
    end

    it "is initializable and assigns the default value if arg1 is not passed in" do
      instance = test_class.new

      expect(instance.send(:arg1)).to eq("default_value")
    end
  end

  context "when there is an argument that coerces input" do
    before do
      test_class.required(:arg1, Definition.CoercibleType(Integer))
    end

    it "is initializable with a string and the private accessor returns the coerced value" do
      instance = test_class.new(arg1: "1")

      expect(instance.send(:arg1)).to eq(1)
    end
  end
end
