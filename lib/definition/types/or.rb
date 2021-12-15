# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Or < Base
      module Dsl
        def validate(definition)
          definitions << definition
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
            error = ConformError.new(definition,
                                     "None of the definitions are valid for '#{definition.name}'."\
                                     " Errors for last tested definition:",
                                     sub_errors: result)
            ConformResult.new(value, errors: [error])
          end
        end

        private

        def first_successful_conform_or_errors(value)
          errors = []
          definition.definitions.each do |definition|
            result = definition.conform(value)
            return result if result.passed?

            errors = result.error_tree
          end

          errors.flatten
        end

        attr_accessor :definition
      end
    end
  end
end
