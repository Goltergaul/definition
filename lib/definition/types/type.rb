# frozen_string_literal: true
require "definition/types/base"
require "definition/errors/invalid"

module Definition
  module Types
    class Type < Base
      def initialize(name, klass)
        self.klass = klass
        super(name)
      end

      def conform(value)
        if value.is_a?(klass)
          [:ok, value]
        else
          [:error, [Errors::Invalid.new(value, name: name, definition: self, description: "is_a? #{klass}")]]
        end
      end

      private

      attr_accessor :test, :klass
    end
  end
end
