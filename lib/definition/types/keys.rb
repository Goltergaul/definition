# frozen_string_literal: true

require "definition/types/base"
require "definition/types/include"
require "definition/key_conform_error"

module Definition
  module Types
    class Keys < Base
      module Dsl
        def required(key, definition)
          required_definitions << { key: key, definition: definition }
        end

        def optional(key, definition, **opts)
          optional_definitions << { key: key, definition: definition }
          default(key, opts[:default]) if opts.key?(:default)
        end

        def option(option_name)
          case option_name
          when :ignore_extra_keys
            self.ignore_extra_keys = true
          else
            raise "Option #{option_name} is not defined"
          end
        end

        def include(other)
          raise ArgumentError.new("Included Definition can only be a Keys Definition") unless other.is_a?(Types::Keys)

          ensure_keys_do_not_interfere(other)

          self.required_definitions += other.required_definitions
          self.optional_definitions += other.optional_definitions
          defaults.merge!(other.defaults)
        end

        private

        def default(key, value)
          defaults[key] = value
        end

        def ensure_keys_do_not_interfere(other)
          overlapping_keys = keys & other.keys
          return if overlapping_keys.empty?

          raise ArgumentError.new(
            "Included definition tries to redefine already defined fields: #{overlapping_keys.join(', ')}"
          )
        end
      end

      include Dsl
      attr_accessor :required_definitions, :optional_definitions, :defaults, :ignore_extra_keys

      def initialize(name, req: {}, opt: {}, defaults: {}, options: {})
        super(name)
        self.required_definitions = req.map { |key, definition| { key: key, definition: definition } }
        self.optional_definitions = opt.map { |key, definition| { key: key, definition: definition } }
        self.defaults = defaults
        self.ignore_extra_keys = options.fetch(:ignore_extra_keys, false)
      end

      def conform(value)
        Conformer.new(self, value).conform
      end

      def keys
        (required_definitions + optional_definitions).map { |hash| hash[:key] }
      end

      class Conformer
        def initialize(definition, value)
          self.definition = definition
          self.value = value
          self.errors = []
          @conform_result_value = {} # This will be the output value after conforming
          @not_conformed_value_keys = value.dup # Used to track which keys are left over in the end (unexpected keys)
        end

        def conform
          return invalid_input_result unless valid_input_type?

          values = conform_all_keys
          add_extra_key_errors unless definition.ignore_extra_keys

          ConformResult.new(values, errors: errors)
        end

        private

        attr_accessor :errors

        def invalid_input_result
          errors = [ConformError.new(definition,
                                     "#{definition.name} is not a Hash",
                                     i18n_key: "keys.not_a_hash")]
          ConformResult.new(value, errors: errors)
        end

        def valid_input_type?
          value.is_a?(Hash)
        end

        def add_extra_key_errors
          extra_keys = @not_conformed_value_keys.keys
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
          conform_definitions(definition.required_definitions, required: true)
          conform_definitions(definition.optional_definitions, required: false)

          @conform_result_value
        end

        def conform_definitions(keys, required:)
          keys.each do |hash|
            key = hash[:key]
            key_definition = hash[:definition]
            conform_definition(key, key_definition, required: required)
          end
        end

        # Rubcop rules are disabled for performance optimization purposes
        def conform_definition(key, key_definition, required:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
          @not_conformed_value_keys.delete(key) # Keys left over in that hash at the end are considered unexpected

          # If the input value is missing a key:
          # a) add a missing key error if it is a required key
          # b) otherwise initialize the missing key in the output value if a default value is configured
          unless value.key?(key)
            errors.push(missing_key_error(key)) if required
            @conform_result_value[key] = definition.defaults[key] if definition.defaults.key?(key)
            return
          end

          # If the input value has a key then its value is conformed against the configured definition
          result = key_definition.conform(value[key])
          @conform_result_value[key] = result.value
          return if result.passed?

          errors.push(KeyConformError.new(key_definition,
                                          "#{definition.name} fails validation for key #{key}",
                                          key:        key,
                                          sub_errors: result.error_tree))
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
