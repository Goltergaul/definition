# frozen_string_literal: true

require "definition/types/base"
require "definition/types/error_renderers/lambda"

module Definition
  module Types
    class Lambda < Base
      attr_accessor :conformity_test_lambda

      def initialize(name, context: {}, &conformity_test_lambda)
        self.conformity_test_lambda = conformity_test_lambda
        super(name, context: context)
      end

      def conform(value)
        Conformer.new(self).conform(value)
      end

      def error_renderer
        ErrorRenderers::Lambda
      end

      class Conformer
        module Dsl
          def conform_with(value)
            ConformResult.new(value)
          end

          def fail_with(error_message)
            @error_message = error_message
          end
        end
        include Dsl

        def initialize(definition)
          @definition = definition
        end

        def conform(value)
          lambda_result = instance_exec(value, &@definition.conformity_test_lambda)
          return lambda_result if lambda_result.is_a?(ConformResult)

          failure_result_with(value)
        end

        private

        def standard_error_message
          "Did not pass test for #{@definition.name}"
        end

        def contextual_error_message
          return standard_error_message if @definition.context.empty?

          "#{standard_error_message} (#{@definition.context.values.join(',')})"
        end

        def failure_result_with(value)
          ConformResult.new(value, errors: [
                              ConformError.new(@definition,
                                               contextual_error_message,
                                               translated_message: @error_message)
                            ])
        end
      end
    end
  end
end
