# frozen_string_literal: true

# frozen_string_literal: true
require "definition/types/base"
require "definition/errors/invalid"

module Definition
  module Types
    class Include < Base
      def initialize(name, *args)
        self.required_items = *args
        super(name)
      end

      def conform(value)
        errors = []
        required_items.each do |item|
          unless value.include?(item)
            errors.push(Errors::Invalid.new(value,
                                            name: name,
                                            description: "include? #{item.inspect}",
                                            definition: self))
          end
        end

        if errors.size == 0
          [:ok, value]
        else
          [:error, errors]
        end
      end

      private

      attr_accessor :required_items
    end
  end
end
