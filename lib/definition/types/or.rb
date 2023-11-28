# frozen_string_literal: true

require "definition/types/base"
require "definition/types/error_renderers/leaf"

module Definition
  module Types
    class Or < Base
      module Dsl
        def validate(definition)
          definitions << definition
        end
      end

      include Dsl
      attr_reader :definitions

      def initialize(name, *args)
        @definitions = *args
        super(name)
      end

      def conform(value)
        last_result = nil
        @definitions.each do |definition|
          last_result = definition.conform(value)
          return last_result if last_result.passed?
        end

        ConformResult.new(value, errors: [
                            ConformError.new(self,
                                             "None of the definitions are valid for '#{name}'."\
                                             " Errors for last tested definition:",
                                             sub_errors: last_result.error_tree)
                          ])
      end

      def error_renderer
        ErrorRenderers::Leaf
      end
    end
  end
end
