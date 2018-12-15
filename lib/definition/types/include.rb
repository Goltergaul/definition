# frozen_string_literal: true

# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Include < Base
      attr_accessor :required_items

      def initialize(name, *args)
        self.required_items = *args
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
            ConformResult.new(value, errors: errors)
          end
        end

        private

        def gather_errors(value)
          definition.required_items.map do |item|
            next if value.include?(item)
            ConformError.new(definition, "#{definition.name} does not include #{item}")
          end.compact
        end

        attr_accessor :definition
      end
    end
  end
end
