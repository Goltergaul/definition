# frozen_string_literal: true

module Definition
  module Types
    class Base
      attr_accessor :name

      def initialize(name)
        self.name = name
      end

      def explain(value)
        status, result = conform(value)
        return "value passes definition" if status == :ok

        result.map(&:message).join("\n")
      end
    end
  end
end
