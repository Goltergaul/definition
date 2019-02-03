# frozen_string_literal: true

require "definition/conform_result"
require "definition/conform_error"

module Definition
  module Types
    class Base
      attr_accessor :name, :context

      def initialize(name, context: {})
        self.name = name
        self.context = context
      end

      def explain(value)
        result = conform(value)
        return "value passes definition" if result.passed?

        result.error_message
      end

      def conform(_value)
        raise NotImplementedError
      end
    end
  end
end
