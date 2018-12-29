# frozen_string_literal: true

# frozen_string_literal: true

require "definition/types/base"
require "definition/types/include"

module Definition
  module Types
    class Keys < Base
      module Dsl
        def required(key, definition)
          required_definitions[key] = definition
        end

        def optional(key, definition)
          optional_definitions[key] = definition
        end
      end

      include Dsl
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

          ConformResult.new(values, errors: errors)
        end

        private

        attr_accessor :errors

        def add_extra_key_errors
          extra_keys = value.keys - all_keys
          return if extra_keys.empty?

          errors.push(ConformError.new(
                        definition,
                        "#{definition.name} has extra keys: #{extra_keys.map(&:inspect).join(', ')}"
                      ))
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
          keys.each_with_object({}) do |(key, key_definition), result_value|
            next unless value.key?(key)

            result = key_definition.conform(value[key])
            result_value[key] = result.result
            next if result.passed?

            errors.push(ConformError.new(key_definition,
                                         "#{definition.name} fails validation for key #{key}",
                                         sub_errors: result.errors))
          end
        end

        def add_missing_key_errors
          required_definition = Types::Include.new(
            definition.name,
            *required_keys
          )

          result = required_definition.conform(value)
          return if result.passed?

          errors.concat(result.errors)
        end

        attr_accessor :definition, :value
      end
    end
  end
end
