# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class And < Base
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
          results = conform_all(value)

          if results.all? { |r| r.errors.empty? }
            ConformResult.new(results.last.result)
          else
            ConformResult.new(value, errors: [
              ConformError.new(definition, "Not all children are valid for #{definition.name}",
                               sub_errors: results.map { |r| r.errors }.flatten
              )
            ])
          end
        end

        private

        attr_accessor :definition

        def conform_all(value)
          results = []
          definition.definitions.each do |definition|
            result = definition.conform(value)
            value = result.result
            results << result
          end
          results
        end
      end
    end
  end
end
