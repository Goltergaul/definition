# frozen_string_literal: true

require "definition/types/base"

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

      class Conformer
        def initialize(definition)
          self.definition = definition
        end

        def conform(value)
          return non_array_error(value) unless value.is_a?(Array)
          results = conform_all(value)

          if results.all? { |r| r.errors.empty? }
            ConformResult.new(results.map(&:result))
          else
            ConformResult.new(value, errors: [
              ConformError.new(definition,
                              "Not all items conform with #{definition.name}",
                               sub_errors: errors(results)
              )
            ])
          end
        end

        private

        attr_accessor :definition

        def errors(results)
          results.reject { |r| r.passed? }.map do |r|
            ConformError.new(
              definition,
              "Item #{r.result.inspect} did not conform to #{definition.name}",
              sub_errors: r.errors
            )
          end
        end

        def conform_all(values)
          values.map do |value|
            definition.item_definition.conform(value)
          end
        end

        def non_array_error(value)
          ConformResult.new(value, errors: [
            ConformError.new(definition,
                            "Non-Array value does not conform with #{definition.name}"
            )
          ])
        end
      end
    end
  end
end
