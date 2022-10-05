# frozen_string_literal: true

require "spec_helper"

describe Definition::Model do
  let(:test_model_class) do
    Class.new(described_class) do
      required :name, Definition.Type(String)
      optional :email, Definition.Type(String)
    end
  end

  describe "model instantiation" do
    context "with an unconfigured model" do
      let(:test_model_class) do
        Class.new(described_class)
      end

      it "instantiates the model" do
        test_model_class.new({})
      end
    end

    context "with hash argument" do
      subject(:new) do
        test_model_class.new(hash_arg)
      end

      context "with required and optional keywords" do
        let(:hash_arg) { { name: "John", email: "test@test.com" } }

        it "instantiates the model" do
          expect(new.name).to eq("John")
          expect(new.email).to eq("test@test.com")
        end

        it "is not possible to change the model data by modifying the passed in hash content" do
          model = new
          hash_arg[:name] = "Joe"

          expect(model.name).to eql("John")
        end
      end
    end

    context "with keyword arguments" do
      subject(:new) do
        test_model_class.new(**kwargs)
      end

      context "with required keywords only" do
        let(:kwargs) { { name: "John" } }

        it "instantiates the model" do
          expect(new.name).to eq("John")
          expect(new.email).to be_nil
        end
      end

      context "with required and optional keywords" do
        let(:kwargs) { { name: "John", email: "test@test.com" } }

        it "instantiates the model" do
          expect(new.name).to eq("John")
          expect(new.email).to eq("test@test.com")
        end
      end

      context "with missing required keyword" do
        let(:kwargs) { { email: "test@test.com" } }

        it "raises an error" do
          expect { new }.to raise_error(Definition::InvalidModelError, "hash is missing key :name")
        end
      end

      context "with unexpected keyword" do
        let(:kwargs) { { name: "John", foo: "bar" } }

        it "raises an error" do
          expect { new }.to raise_error(Definition::InvalidModelError, "hash has extra key: :foo")
        end

        context "when option to ignore extra keys is set" do
          let(:test_model_class) do
            Class.new(described_class) do
              required :name, Definition.Type(String)

              option :ignore_extra_keys
            end
          end

          it "instantiates the model" do
            expect(new.name).to eq("John")
          end
        end
      end
    end

    context "with nested value objects" do
      let(:test_model_class) do
        FooModel = foo_model_class
        Class.new(described_class) do
          required :foo, (Definition.Keys do
            required :array, Definition.Each(Definition.CoercibleModel(FooModel))
          end)
        end
      end
      let(:foo_model_class) do
        Class.new(described_class) do
          required :bar, Definition.Type(String)
        end
      end

      it "can be instantiated with valid input" do
        foo_object = foo_model_class.new(bar: "test")
        expect(test_model_class.new(foo: { array: [foo_object] }).foo[:array].first).to eql(foo_object)
      end

      it "can be instantiated with foo being a hash via coercion" do
        foo_object = foo_model_class.new(bar: "test")

        value_object = test_model_class.new(foo: { array: [{ bar: "test" }] })
        expect(value_object.foo[:array].first).to eq(foo_object)
        expect(value_object.foo[:array].first.bar).to eq("test")
      end

      it "throws error with invalid input" do
        expect do
          test_model_class.new(foo: { array: [{ bar: 2.0 }] })
        end.to raise_error(Definition::InvalidModelError, /bar/)
      end
    end
  end

  describe ".to_h" do
    subject(:to_h) { instance.to_h }

    let(:instance) { test_model_class.new(name: "John") }

    it { is_expected.to eq(name: "John") }

    it "is not frozen" do
      expect(to_h.frozen?).to be false
    end

    context "with optional attributes present" do
      subject(:to_h) { test_model_class.new(name: "John", email: "test@test.com").to_h }

      it { is_expected.to eq(name: "John", email: "test@test.com") }
    end

    it "is not possible to manipulate the model data by manipulating the hash" do
      to_h[:name] = "Joe"

      expect(instance.name).to eq("John")
    end

    context "with nested value objects" do
      let(:test_model_class) do
        FooModel = foo_model_class
        Class.new(described_class) do
          required :foo, (Definition.Keys do
            required :array, Definition.Each(Definition.CoercibleModel(FooModel))
          end)
        end
      end
      let(:foo_model_class) do
        Class.new(described_class) do
          required :bar, Definition.Type(String)
        end
      end

      it "converts deeply nested models into hashes" do
        foo_object = foo_model_class.new(bar: "test")
        expect(test_model_class.new(foo: { array: [foo_object] }).to_h).to eql(
          foo: {
            array: [{ bar: "test" }]
          }
        )
      end
    end
  end

  describe ".== (object equality)" do
    it "returns true if both models have the same content" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "John")

      expect(model_a == model_b).to be true
    end

    it "returns false if both models have different content" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "Marie")

      expect(model_a == model_b).to be false
    end

    it "returns false if a model is compared with its hash representation" do
      model_a = test_model_class.new(name: "John")

      expect(model_a == model_a.to_h).to be false
    end
  end

  describe ".eql?" do
    it "returns true if both models have the same content" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "John")

      expect(model_a.eql?(model_b)).to be true
    end

    it "returns false if both models have different content" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "Marie")

      expect(model_a.eql?(model_b)).to be false
    end

    it "returns false if a model is compared with its hash representation" do
      model_a = test_model_class.new(name: "John")

      expect(model_a.eql?(model_a.to_h)).to be false
    end
  end

  describe ".hash" do
    it "returns the same value for two models with the same content" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "John")

      expect(model_a.hash).to eq(model_b.hash)
    end

    it "returns a different value for two models with different content" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "Marie")

      expect(model_a.hash).not_to eq(model_b.hash)
    end

    it "considers the same model as an identical hash key" do
      model_a = test_model_class.new(name: "John")
      model_b = test_model_class.new(name: "John")
      model_c = test_model_class.new(name: "Marie")

      test_hash = {}
      test_hash[model_a] = "John"
      test_hash[model_b] = "John"
      test_hash[model_c] = "Marie"

      expect(test_hash.keys.size).to be(2)
      expect(test_hash.keys).to eql([model_b, model_c])
    end
  end

  describe ".new" do
    subject(:new) { existing_instance.new(email: "test@test.com") }

    let(:existing_instance) { test_model_class.new(name: "John") }

    it "merges the new input with the existing data to create a new model" do
      expect(new).to eq(test_model_class.new(name: "John", email: "test@test.com"))
    end
  end
end
