# frozen_string_literal: true

module Definition
  module Dsl
    module Nil
      # Example:
      # Nil
      def Nil # rubocop:disable Naming/MethodName
        Types::Nil.new
      end
    end
  end
end
