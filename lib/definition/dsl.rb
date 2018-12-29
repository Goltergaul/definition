# frozen_string_literal: true

require "definition/types"

module Definition
  module Dsl
    # Example:
    # Keys do
    #   required :name, Types::Type(String)
    #   optional :age, Types::Type(Integer)
    # end
    def Keys(&block) # rubocop:disable Naming/MethodName
      Types::Keys.new(:hash).tap do |instance|
        instance.instance_exec(&block)
      end
    end

    # Example:
    # And(Types::Type(Float), Types::GreaterThen(10.0))
    def And(*definitions) # rubocop:disable Naming/MethodName
      Types::And.new(:and, *definitions)
    end

    # Example:
    # Or(Types::Type(Float), Types::Type(Integer))
    def Or(*definitions) # rubocop:disable Naming/MethodName
      Types::Or.new(:or, *definitions)
    end

    # Example:
    # Type(Integer)
    def Type(klass) # rubocop:disable Naming/MethodName
      Types::Type.new(:type, klass)
    end

    # Example:
    # CoercibleType(Integer)
    def CoercibleType(klass) # rubocop:disable Naming/MethodName
      unless Kernel.respond_to?(klass.name)
        raise ArgumentError.new("#{klass} can't be used as CoercibleType because its not "\
                                "a primitive that has a coersion function defined")
      end
      Types::Type.new(:type, klass) do |value|
        begin
          method(klass.name).call(value)
        rescue ArgumentError
          value
        end
      end
    end

    # Example:
    # Lambda(:even) do |value|
    #   value.even?
    # end
    def Lambda(name, &block) # rubocop:disable Naming/MethodName
      Types::Lambda.new(name, &block)
    end

    # Example:
    # Enum("allowed_value1", "allowed_value2")
    def Enum(*allowed_values) # rubocop:disable Naming/MethodName
      Lambda("enum #{allowed_values.inspect}") do |value|
        conform_with(value) if allowed_values.include?(value)
      end
    end

    # Example:
    # Each(Definition::Type(Integer))
    def Each(definition) # rubocop:disable Naming/MethodName
      Types::Each.new(:each, definition: definition)
    end
  end
end
