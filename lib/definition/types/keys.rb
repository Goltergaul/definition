# frozen_string_literal: true

# frozen_string_literal: true

require "definition/types/base"
require "definition/types/include"
require "definition/errors/invalid"

module Definition
  module Types
    class Keys < Base
      attr_accessor :required_definitions, :optional_definitions

      def initialize(name, req: {}, opt: {})
        super(name)
        self.required_definitions = req
        self.optional_definitions = opt
      end

      def conform(value)
        Conformer.new(self, value).conform
      end

      class Conformer
        def initialize(definition, value)
          self.definition = definition
          self.value = value
          self.errors = []
        end

        def conform
          add_extra_key_errors
          add_missing_key_errors
          values = conform_all_keys

          return [:error, [error]] unless errors.empty?

          [:ok, values]
        end

        private

        attr_accessor :errors

        def error
          description = "keys? req: [#{required_keys.join(' ')}] opt: [#{optional_keys.join(' ')}]"
          Errors::Invalid.new(value,
                              name:        definition.name,
                              description: description,
                              definition:  definition,
                              children:    errors)
        end

        def add_extra_key_errors
          extra_keys = value.keys - all_keys
          return if extra_keys.empty?
          errors.push(Errors::Invalid.new(value,
                                          name:        definition.name,
                                          description: "unexpected keys: [#{extra_keys.join(' ')}]",
                                          definition:  definition))
        end

        def conform_all_keys
          required_keys_values = conform_definitions(required_definitions)
          optional_keys_values = conform_definitions(optional_definitions)

          required_keys_values.merge!(optional_keys_values)
        end

        def all_keys
          required_keys + optional_keys
        end

        def required_definitions
          definition.required_definitions
        end

        def required_keys
          required_definitions.keys
        end

        def optional_definitions
          definition.optional_definitions
        end

        def optional_keys
          optional_definitions.keys
        end

        def conform_definitions(keys)
          keys.each_with_object({}) do |(key, key_definition), result|
            next unless value.key?(key)
            status, result_value = key_definition.conform(value[key])
            result[key] = result_value if status == :ok
            next unless status == :error
            errors.push(Errors::Invalid.new(value, name:        key.to_s,
                                                   description: "key #{key}",
                                                   definition:  definition,
                                                   children:    result_value))
          end
        end

        def add_missing_key_errors
          required_definition = Types::Include.new(
            definition.name,
            *required_keys
          )

          status, result = required_definition.conform(value)
          return if status == :ok
          errors.concat(result)
        end

        attr_accessor :definition, :value
      end
    end
  end
end
