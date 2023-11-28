# frozen_string_literal: true

require "definition/types/base"

module Definition
  module Types
    class Nil < Base
      def initialize
        super(:nil)
      end

      def conform(value)
        if value.nil?
          ConformResult.new(value)
        else
          ConformResult.new(value, errors: [
                              ConformError.new(self, "Did not pass test for nil")
                            ])
        end
      end
    end
  end
end
