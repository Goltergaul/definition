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

          required_definitions.merge!(other.required_definitions)
          optional_definitions.merge!(other.optional_definitions)
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
        self.required_definitions = req
        self.optional_definitions = opt
        self.defaults = defaults
        self.ignore_extra_keys = options.fetch(:ignore_extra_keys, false)
      end

      def initialize_dup(_other)
        super
        self.required_definitions = required_definitions.dup
        self.optional_definitions = optional_definitions.dup
        self.defaults = defaults.dup
      end

      def conform(input_value) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
        # input_value is duplicated because we don't want to modify the user object that is passed into this function.
        # The following logic will iterate over each definition and delete the key associated with the definition from
        # the input value.
        # In the end if there are still keys on the object and 'ignore_extra_keys' is false, an error will be raised.
        value = input_value.dup
        result_value = {}
        errors = []

        return wrong_type_result(value) unless value.is_a?(Hash)

        required_definitions.each do |key, definition|
          if value.key?(key)
            result = definition.conform(value.delete(key))
            result_value[key] = result.value
            next if result.passed?

            errors.push(key_error(definition, key, result))
          else
            errors << missing_key_error(key)
          end
        end

        optional_definitions.each do |key, definition|
          if value.key?(key)
            result = definition.conform(value.delete(key))
            result_value[key] = result.value
            next if result.passed?

            errors.push(key_error(definition, key, result))
          elsif defaults.key?(key)
            result_value[key] = defaults.fetch(key)
          end
        end

        if !ignore_extra_keys && !value.keys.empty?
          value.keys.each do |key|
            errors << extra_key_error(key)
          end
        end

        ConformResult.new(result_value, errors: errors)
      end

      def keys
        required_definitions.keys + optional_definitions.keys
      end

      private

      def wrong_type_result(value)
        ConformResult.new(value, errors: [
                            ConformError.new(
                              self,
                              "#{name} is not a Hash",
                              i18n_key: "keys.not_a_hash"
                            )
                          ])
      end

      def extra_key_error(key)
        KeyConformError.new(
          self,
          "#{name} has extra key: #{key.inspect}",
          key:      key,
          i18n_key: "keys.has_extra_key"
        )
      end

      def missing_key_error(key)
        KeyConformError.new(self,
                            "#{name} is missing key #{key.inspect}",
                            key:      key,
                            i18n_key: "keys.has_missing_key")
      end

      def key_error(definition, key, result)
        KeyConformError.new(definition,
                            "#{name} fails validation for key #{key}",
                            key:        key,
                            sub_errors: result.error_tree)
      end
    end
  end
end
