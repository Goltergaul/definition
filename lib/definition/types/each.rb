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

      def conform(value)
        Conformer.new(self).conform(value)
      end

      def error_renderer
        ErrorRenderers::Leaf
      end

      class Conformer
        def initialize(definition)
          self.definition = definition
        end

        def conform(value)
          return non_array_error(value) unless value.is_a?(Array)

          results = conform_all(value)

          if results.all?(&:conformed?)
            ConformResult.new(results.map(&:value))
          else
            ConformResult.new(value, errors: [ConformError.new(definition,
                                                               "Not all items conform with '#{definition.name}'",
                                                               sub_errors: errors(results))])
          end
        end

        private

        attr_accessor :definition

        def errors(results)
          errors = []
          results.each_with_index do |result, index|
            next if result.passed?

            errors << KeyConformError.new(
              definition,
              "Item #{result.value.inspect} did not conform to #{definition.name}",
              key:        index,
              sub_errors: result.error_tree
            )
          end
          errors
        end

        def conform_all(values)
          values.map do |value|
            definition.item_definition.conform(value)
          end
        end

        def non_array_error(value)
          ConformResult.new(value, errors: [
                              ConformError.new(definition,
                                               "Non-Array value does not conform with #{definition.name}")
                            ])
        end
      end
    end
  end
end
