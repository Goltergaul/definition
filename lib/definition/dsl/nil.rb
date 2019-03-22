# frozen_string_literal: true

module Definition
  module Dsl
    module Nil
      # Example:
      # Nil
      def Nil # rubocop:disable Style/MethodName
        Types::Lambda.new(:nil) do |value|
          conform_with(value) if value.nil?
        end
      end
    end
  end
end
