# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class And < Base
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
          results = conform_all(value)

          if results.all?(&:conformed?)
            ConformResult.new(results.last.value)
          else
            ConformResult.new(value, errors: [
                                ConformError.new(definition, "Not all definitions are valid for #{definition.name}",
                                                 sub_errors: results.map(&:error_tree).flatten)
                              ])
          end
        end

        private

        attr_accessor :definition

        def conform_all(value)
          results = []
          definition.definitions.each do |definition|
            result = definition.conform(value)
            value = result.value
            results << result
          end
          results
        end
      end
    end
  end
end
