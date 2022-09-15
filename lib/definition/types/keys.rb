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
          other.required_definitions.each do |hash|
            required(hash[:key], hash[:definition])
          end
          other.optional_definitions.each do |hash|
            optional(hash[:key], hash[:definition])
          end
          other.defaults.each do |key, default|
            default(key, default)
          end
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
          @conform_result_value = {}
        end

        def conform
          if valid_input_type?
            @not_conformed_value_keys = value.dup
            values = conform_all_keys
            add_extra_key_errors unless definition.ignore_extra_keys
          else
            errors.push(ConformError.new(definition,
                                         "#{definition.name} is not a Hash",
                                         i18n_key: "keys.not_a_hash"))
          end

          ConformResult.new(values, errors: errors)
        end

        private

        attr_accessor :errors

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
            @not_conformed_value_keys.delete(key)
            unless value.key?(key)
              errors.push(missing_key_error(key)) if required
              @conform_result_value[key] = definition.defaults[key] if definition.defaults.key?(key)
              next
            end

            result = key_definition.conform(value[key])
            @conform_result_value[key] = result.value
            next if result.passed?

            errors.push(KeyConformError.new(key_definition,
                                            "#{definition.name} fails validation for key #{key}",
                                            key:        key,
                                            sub_errors: result.error_tree))
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
