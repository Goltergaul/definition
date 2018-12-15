# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Lambda < Base
      def initialize(name, test_lambda)
        self.test_lambda = test_lambda
        super(name)
      end

      def conform(value)
        if test_lambda.call(value)
          ConformResult.new(value)
        else
          ConformResult.new(value, errors: [
            ConformError.new(self, "Did not pass test for #{name}")
          ])
        end
      end

      private

      attr_accessor :test, :test_lambda
    end
  end
end
