# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Lambda < Base
      module Dsl
        def conform_with(value)
          ConformResult.new(value)
        end
      end

      include Dsl
      def initialize(name, &test_lambda)
        self.test_lambda = test_lambda
        super(name)
      end

      def conform(value)
        lambda_result = instance_exec(value, &test_lambda)
        return lambda_result if lambda_result.is_a?(ConformResult)

        ConformResult.new(value, errors: [
                            ConformError.new(self, "Did not pass test for #{name}")
                          ])
      end

      private

      attr_accessor :test, :test_lambda
    end
  end
end
