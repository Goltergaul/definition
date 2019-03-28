# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Type < Base
      def initialize(name, klass, &coerce)
        raise "#{klass.inspect} is not a class" unless klass.is_a?(Class)

        self.klass = klass
        self.coerce = coerce
        super(name, context: { class: klass })
      end

      def conform(value)
        value = coerce.call(value) if coerce && !valid?(value)

        try_conform(value)
      end

      private

      def valid?(value)
        value.is_a?(klass)
      end

      def try_conform(value)
        if valid?(value)
          ConformResult.new(value)
        else
          ConformResult.new(value, errors: [
                              ConformError.new(self, "Is of type #{value.class.name} instead of #{klass.name}")
                            ])
        end
      end

      attr_accessor :test, :klass, :coerce
    end
  end
end
