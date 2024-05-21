# frozen_string_literal: true

module Definition
  class InvalidModelError < StandardError
    attr_accessor :conform_result

    def initialize(conform_result)
      super(conform_result.error_message)
      self.conform_result = conform_result
    end
  end

  class Model
    class << self
      def conform(value)
        _definition.conform(value)
      end

      def required(key, definition)
        _define_attr_accessor(key)
        _definition.required(key, definition)
      end

      def optional(key, definition, **opts)
        _define_attr_accessor(key)
        _definition.optional(key, definition, **opts)
      end

      def option(option_name)
        _definition.option(option_name)
      end

      def _define_attr_accessor(key)
        define_method(key) do
          @_attributes.fetch(key, nil)
        end
      end

      def _definition
        @_definition ||= if superclass == ::Definition::Model
                           ::Definition.Keys {}
                         else
                           # Create a deep copy of parent's definition
                           Marshal.load(Marshal.dump(superclass._definition))
                         end
      end
    end

    def initialize(hash = nil, **kwargs)
      result = self.class.conform(hash || kwargs)
      raise InvalidModelError.new(result) unless result.passed?

      @_attributes = result.value.freeze
    end

    def new(**kwargs)
      self.class.new(**to_h.merge!(kwargs))
    end

    def ==(other)
      return false unless other.is_a?(self.class)

      @_attributes.hash == other.instance_variable_get(:@_attributes).hash
    end
    alias eql? ==

    def hash
      @_attributes.hash
    end

    def to_h
      _deep_transform_values_in_object(@_attributes) do |value|
        value.is_a?(::Definition::Model) ? value.to_h : value
      end
    end

    private

    def _deep_transform_values_in_object(object, &block)
      case object
      when Hash
        object.transform_values { |value| _deep_transform_values_in_object(value, &block) }
      when Array
        object.map { |e| _deep_transform_values_in_object(e, &block) }
      else
        yield(object)
      end
    end
  end
end
