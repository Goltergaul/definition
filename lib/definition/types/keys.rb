# frozen_string_literal: true

# frozen_string_literal: true
require "definition/types/base"
require "definition/types/include"
require "definition/errors/invalid"

module Definition
  module Types
    class Keys < Base
      attr_accessor :required_keys, :optional_keys

      def initialize(name, req: {}, opt: {})
        super(name)
        self.required_keys = req
        self.optional_keys = opt
        self.required_definition = Types::Include.new(name, *required_keys.keys)
      end

      def conform(value)
        errors = []
        conform_result = {}
        status, result_value = required_definition.conform(value)
        errors.concat(result_value) if status == :error

        all_keys = value.keys

        if status == :ok
          required_keys.each do |key, definition|
            status, result_value = definition.conform(value[key])
            if status == :ok
              conform_result[key] = result_value
            else
              errors.push(Errors::Invalid.new(value,
                                              name: key.to_s,
                                           description: "key #{key}",
                                           definition: self,
                                           children: result_value))
            end
            all_keys.delete(key)
          end
        end

        optional_keys.each do |key, definition|
          next unless value.key?(key)
          status, result_value = definition.conform(value[key])
          if status == :ok
            conform_result[key] = result_value
          else
            errors.push(Errors::Invalid.new(value,
                                            name: key.to_s,
                                         description: "key #{key}",
                                         definition: self,
                                         children: result_value))
          end
          all_keys.delete(key)
        end

        if all_keys.size > 0
          errors.push(Errors::Invalid.new(value,
                                          name: name,
                                          description: "unexpected keys: [#{all_keys.join(" ")}]",
                                          definition: self,
                                          children: []))
        end

        if errors.size > 0
          [:error, [Errors::Invalid.new(value,
                                       name: name,
                                       description: "keys? req: [#{required_keys.keys.join(" ")}] opt: [#{optional_keys.keys.join(" ")}]",
                                       definition: self,
                                       children: errors)]]
        else
          [:ok, conform_result]
        end
      end

      attr_accessor :required_definition
    end
  end
end
