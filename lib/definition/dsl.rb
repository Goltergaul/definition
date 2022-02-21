# frozen_string_literal: true

require "definition/types"

module Definition
  module Dsl
    # Example:
    # Keys do
    #   required :name, Types::Type(String)
    #   optional :age, Types::Type(Integer)
    # end
    def Keys(&block) # rubocop:disable Style/MethodName
      Types::Keys.new(:hash).tap do |instance|
        instance.instance_exec(&block)
      end
    end

    # Example:
    # And(Types::Type(Float), Types::GreaterThen(10.0))
    def And(*definitions) # rubocop:disable Style/MethodName
      Types::And.new(:and, *definitions)
    end

    # Example:
    # Or(Types::Type(Float), Types::Type(Integer))
    def Or(*definitions) # rubocop:disable Style/MethodName
      Types::Or.new(:or, *definitions)
    end

    # Example:
    # Type(Integer)
    def Type(klass) # rubocop:disable Style/MethodName
      Types::Type.new(:type, klass)
    end

    # Example:
    # CoercibleType(Integer)
    def CoercibleType(klass) # rubocop:disable Style/MethodName
      unless Kernel.respond_to?(klass.name)
        raise ArgumentError.new("#{klass} can't be used as CoercibleType because its not "\
                                "a primitive that has a coercion function defined")
      end
      Types::Type.new(:type, klass) do |value|
        method(klass.name).call(value)
      rescue ArgumentError
        value
      end
    end

    # Example:
    # Lambda(:even) do |value|
    #   value.even?
    # end
    def Lambda(name, context: {}, &block) # rubocop:disable Style/MethodName
      Types::Lambda.new(name, context: context, &block)
    end

    # Example:
    # Enum("allowed_value1", "allowed_value2")
    def Enum(*allowed_values) # rubocop:disable Style/MethodName
      Lambda("enum", context: { allowed_values: allowed_values }) do |value|
        conform_with(value) if allowed_values.include?(value)
      end
    end

    # Example:
    # Each(Definition::Type(Integer))
    def Each(definition) # rubocop:disable Style/MethodName
      Types::Each.new(:each, definition: definition)
    end

    # Example:
    # Boolean
    def Boolean # rubocop:disable Style/MethodName
      Types::Or.new(:boolean, Type(TrueClass), Type(FalseClass))
    end

    # Example:
    # CoercibleValueObject(ValueObjectClass)
    def CoercibleValueObject(klass) # rubocop:disable Style/MethodName
      Types::Or.new(:coercible_value_object,
                    Definition.Type(klass), # If its of ther correct type already this will let it pass already
                    And(
                      klass, # First make sure that the input could be coerced to 'klass'
                      Lambda("value_object_coercion", context: { value_object_class: klass }) do |value|
                        conform_with(klass.new(value)) # Actually coerce the input to klass
                      end
                    ))
    end

    # Example:
    # Nilable(Definition.Type(Integer))
    def Nilable(definition) # rubocop:disable Style/MethodName
      Types::Or.new(:nilable, Nil(), definition)
    end
  end
end
