# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Or < Base
      module Dsl
        def validate(definition)
          self.definitions << definition
        end
      end

      include Dsl
      attr_accessor :definitions

      def initialize(name, *args)
        self.definitions = *args
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
          result = first_successful_conform_or_errors(value)
          if result.is_a?(ConformResult)
            result
          else
            ConformResult.new(value, errors: [
              ConformError.new(definition, "None of the children are valid for #{definition.name}",
                sub_errors: result
              )
            ])
          end
        end

        private

        def first_successful_conform_or_errors(value)
          errors = []
          success_result = definition.definitions.find do |definition|
            result = definition.conform(value)
            if result.passed?
              return result
            else
              errors.push(result.errors)
              nil
            end
          end

          errors.flatten
        end

        attr_accessor :definition
      end
    end
  end
end
