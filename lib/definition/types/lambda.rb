# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Lambda < Base
      module Dsl
        def conform_with(value)
          ConformResult.new(value)
        end

        def fail_with(error_message)
          self.error_message = error_message
        end
      end
      include Dsl

      def initialize(name, context: {}, &test_lambda)
        self.test_lambda = test_lambda
        super(name, context: context)
      end

      def conform(value)
        lambda_result = instance_exec(value, &test_lambda)
        return lambda_result if lambda_result.is_a?(ConformResult)

        failure_result_with(value, error_message)
      end

      private

      attr_writer :error_message

      def error_message
        @error_message || "Did not pass test for #{name}"
      end

      def failure_result_with(value, error_message)
        ConformResult.new(value, errors: [
                            ConformError.new(self, error_message)
                          ])
      end

      attr_accessor :test, :test_lambda
    end
  end
end
