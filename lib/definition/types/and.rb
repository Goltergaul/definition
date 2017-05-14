# frozen_string_literal: true

require "definition/types/base"
require "definition/errors/invalid"

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
            [:ok, value]
          else
            [:error, [Errors::Invalid.new(value,
                                          name:        definition.name,
                                          description: "and: [#{definition.definitions.map(&:name).join(' ')}]",
                                          definition:  definition,
                                          children:    errors)]]
          end
        end

        private

        attr_accessor :definition

        def gather_errors(value)
          errors = []
          definition.definitions.each do |definition|
            status, result = definition.conform(value)
            errors.push(result) if status == :error
          end
          errors.flatten!
          errors
        end
      end
    end
  end
end
