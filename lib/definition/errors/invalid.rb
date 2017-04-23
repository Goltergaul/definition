# frozen_string_literal: true

module Definition
  module Errors
    class Invalid
      attr_accessor :value, :name, :description, :definition, :children

      def initialize(value, name:, description:, definition:, children: [])
        self.value = value
        self.name = name
        self.description = description
        self.definition = definition
        self.children = children
      end

      def message(path: [])
        if children.empty?
          message = ""
          message += "In: [#{path.join("/")}] " unless path.empty?
          message += "val: #{value.inspect} fails definition: '#{name} #{description}' (#{definition.class})"

          return message
        end

        result = []
        children.each do |error|
          result.push(error.message(path: path+[name]))
        end

        result.join("\n")
      end

      def to_h
        {
          value: value,
          name: name,
          description: description,
          children: children.map(&:to_h)
        }
      end
    end
  end
end
