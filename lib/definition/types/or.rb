# frozen_string_literal: true
require "definition/types/base"
require "definition/errors/invalid"

module Definition
  module Types
    class Or < Base
      def initialize(name, *args)
        self.definitions = *args
        super(name)
      end

      def conform(value)
        errors = []
        success_result = definitions.detect do |definition|
          status, result = definition.conform(value)
          errors.push(result) if status == :error
          break result if status == :ok
        end

        if success_result
          [:ok, success_result]
        else
          errors.flatten!
          [:error, [Errors::Invalid.new(value,
                                      name: name,
                                      description: "or: [#{definitions.map(&:name).join(" ")}]",
                                      definition: self,
                                      children: errors)]]
        end
      end

      private

      attr_accessor :definitions
    end
  end
end
