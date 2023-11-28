# frozen_string_literal: true

require "definition/types/base"
require "definition/types/error_renderers/leaf"

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
        last_result = nil
        definitions.each do |definition|
          last_result = definition.conform(last_result.nil? ? value : last_result.value)
          next if last_result.passed?

          return ConformResult.new(last_result.value, errors: [
                                     ConformError.new(self, "Not all definitions are valid for '#{name}'",
                                                      sub_errors: last_result.error_tree)
                                   ])
        end

        ConformResult.new(last_result.value)
      end

      def error_renderer
        ErrorRenderers::Leaf
      end
    end
  end
end
