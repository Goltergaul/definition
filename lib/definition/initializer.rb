# frozen_string_literal: true

module Definition
  module Initializer
    class InvalidArgumentError < ArgumentError
      attr_accessor :conform_result

      def initialize(conform_result)
        super("Arguments passed into the initializer are invalid: #{conform_result.error_message}")
        self.conform_result = conform_result
      end
    end

    module ClassMethods
      def required(name, *args)
        _keys_definition.required(name, *args)
        _define_attr_accessor(name)
      end

      def optional(name, *args, **kwargs)
        _keys_definition.optional(name, *args, **kwargs)
        _define_attr_accessor(name)
      end

      def _keys_definition
        @_keys_definition ||= Definition.Keys {}
      end

      def _define_attr_accessor(key)
        define_method(key) do
          @_attributes.fetch(key, nil)
        end
        define_method("#{key}=") do |value|
          @_attributes[key] = value
        end
        protected key
        protected "#{key}="
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def initialize(**kwargs)
      result = self.class._keys_definition.conform(kwargs)
      raise InvalidArgumentError.new(result) unless result.passed?

      @_attributes = result.value
    end
  end
end
