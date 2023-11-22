# frozen_string_literal: true

require "definition/types/base"
require "definition/types/error_renderers/leaf"

module Definition
  module Types
    class Each < Base
      attr_accessor :item_definition

      def initialize(name, definition:)
        self.item_definition = definition
        super(name)
      end

      def conform(values)
        return non_array_error(values) unless values.is_a?(Array)

        errors = false

        results = values.map do |value|
          result = item_definition.conform(value)
          errors = true unless result.passed?
          result
        end

        return ConformResult.new(results.map(&:value)) unless errors

        ConformResult.new(values, errors: [ConformError.new(self,
                                                            "Not all items conform with '#{name}'",
                                                            sub_errors: convert_errors(results))])
      end

      def error_renderer
        ErrorRenderers::Leaf
      end

      private

      def convert_errors(results)
        errors = []
        results.each_with_index do |result, index|
          next if result.passed?

          errors << KeyConformError.new(
            self,
            "Item #{result.value.inspect} did not conform to #{name}",
            key:        index,
            sub_errors: result.error_tree
          )
        end
        errors
      end

      def non_array_error(value)
        ConformResult.new(value, errors: [
                            ConformError.new(self,
                                             "Non-Array value does not conform with #{name}")
                          ])
      end
    end
  end
end
