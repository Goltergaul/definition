# frozen_string_literal: true

# frozen_string_literal: true

require "definition/types/base"
require "definition/types/include"
require "definition/key_conform_error"

module Definition
  module Types
    class Keys < Base
      module Dsl
        def required(key, definition)
          required_definitions[key] = definition
        end

        def optional(key, definition, **opts)
          optional_definitions[key] = definition
          default(key, opts[:default]) if opts.key?(:default)
        end

        def default(key, value)
          defaults[key] = value
        end

        def option(option_name)
          case option_name
          when :ignore_extra_keys
            self.ignore_extra_keys = true
          else
            raise "Option #{option_name} is not defined"
          end
        end
      end

      include Dsl
      attr_accessor :required_definitions, :optional_definitions, :defaults, :ignore_extra_keys

      def initialize(name, req: {}, opt: {}, defaults: {}, options: {})
        super(name)
        self.required_definitions = req
        self.optional_definitions = opt
        self.defaults = defaults
        self.ignore_extra_keys = options.fetch(:ignore_extra_keys, false)
      end

      def conform(value)
        Conformer.new(self, value).conform
      end

      def keys
        required_definitions.keys + optional_definitions.keys
      end

      class Conformer
        def initialize(definition, value)
          self.definition = definition
          self.value = value
          self.errors = []
        end

        def conform
          add_extra_key_errors unless definition.ignore_extra_keys
          add_missing_key_errors
          values = conform_all_keys

          ConformResult.new(values, errors: errors)
        end

        private

        attr_accessor :errors

        def add_extra_key_errors
          extra_keys = value.keys - all_keys
          return if extra_keys.empty?

          extra_keys.each do |key|
            errors.push(KeyConformError.new(
                          definition,
                          "#{definition.name} has extra key: #{key.inspect}",
                          key:      key,
                          i18n_key: "keys.has_extra_key"
                        ))
          end
        end

        def conform_all_keys
          required_keys_values = conform_definitions(required_definitions)
          optional_keys_values = conform_definitions(optional_definitions)

          definition.defaults.merge(required_keys_values.merge!(optional_keys_values))
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
            result_value[key] = result.value
            next if result.passed?

            errors.push(KeyConformError.new(key_definition,
                                            "#{definition.name} fails validation for key #{key}",
                                            key:        key,
                                            sub_errors: result.error_tree))
          end
        end

        def add_missing_key_errors
          required_definition = Types::Include.new(
            definition.name,
            *required_keys
          )

          result = required_definition.conform(value)
          return if result.passed?

          result.errors.each do |error|
            errors.push(missing_key_error(error.key))
          end
        end

        def missing_key_error(key)
          KeyConformError.new(definition,
                              "#{definition.name} is missing key #{key.inspect}",
                              key:      key,
                              i18n_key: "keys.has_missing_key")
        end

        attr_accessor :definition, :value
      end
    end
  end
end
