# frozen_string_literal: true

require "definition/types/base"
require "definition/errors/invalid"

module Definition
  module Types
    class Or < Base
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
          status, result = first_successful_conform(value)
          if status == :ok
            [status, result]
          else
            [:error, [Errors::Invalid.new(value,
                                          name:        definition.name,
                                          description: "or: [#{definition.definitions.map(&:name).join(' ')}]",
                                          definition:  definition,
                                          children:    result)]]
          end
        end

        private

        def first_successful_conform(value)
          errors = []
          success_result = definition.definitions.detect do |definition|
            status, result = definition.conform(value)
            errors.push(result) if status == :error
            break result if status == :ok
          end

          errors.flatten!
          return [:error, errors] if success_result.nil?
          [:ok, success_result]
        end

        attr_accessor :definition
      end
    end
  end
end
