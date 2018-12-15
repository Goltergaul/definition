# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Type < Base
      def initialize(name, klass, coerce: false)
        self.klass = klass
        self.coerce = coerce
        super(name)
      end

      def conform(value)
        unless valid?(value)
          coerced_value = coerced(value)
          return try_conform(coerced_value)
        end

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
            ConformError.new(self, "Is of type #{value.class.name} instead of #{klass.name} for #{name}")
          ])
        end
      end

      def coerced(value)
        return value unless coerce
        coerce.call(value)
      end

      attr_accessor :test, :klass, :coerce
    end
  end
end
