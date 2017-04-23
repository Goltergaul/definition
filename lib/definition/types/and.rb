# frozen_string_literal: true
require "definition/types/base"
require "definition/errors/invalid"

module Definition
  module Types
    class And < Base
      def initialize(name, *args)
        self.required_items = *args
        super(name)
      end

      def conform(value)
        errors = []
        required_items.each do |definition|
          status, result = definition.conform(value)
          if status == :error
            errors << result
          end
        end

        if errors.size == 0
          [:ok, value]
        else
          errors.flatten!
          [:error, [Errors::Invalid.new(value,
                                      name: name,
                                      description: "and: [#{required_items.map(&:name).join(" ")}]",
                                      definition: self,
                                      children: errors)]]
        end
      end

      private

      attr_accessor :required_items
    end
  end
end
