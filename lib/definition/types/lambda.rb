# frozen_string_literal: true

require "definition/types/base"
require "definition/errors/invalid"

module Definition
  module Types
    class Lambda < Base
      def initialize(name, test_lambda)
        self.test_lambda = test_lambda
        super(name)
      end

      def conform(value)
        if test_lambda.call(value)
          [:ok, value]
        else
          [:error, [Errors::Invalid.new(value, name: name, definition: self, description: "lambda?")]]
        end
      end

      private

      attr_accessor :test, :test_lambda
    end
  end
end
