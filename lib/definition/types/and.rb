# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class And < Base
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
          errors = gather_errors(value)

          if errors.empty?
            ConformResult.new(value)
          else
            ConformResult.new(value, errors: [
              ConformError.new(definition, "Not all children are valid for #{definition.name}",
                sub_errors: errors
              )
            ])
          end
        end

        private

        attr_accessor :definition

        def gather_errors(value)
          errors = []
          definition.definitions.each do |definition|
            result = definition.conform(value)
            errors.push(result.errors) unless result.passed?
          end
          errors.flatten!
          errors
        end
      end
    end
  end
end
