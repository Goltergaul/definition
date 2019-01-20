# frozen_string_literal: true

require "active_support/core_ext/hash"

module Definition
  class ConformResult
    def initialize(value, errors: [])
      self.value = value
      self.conform_errors = errors
    end

    attr_accessor :value

    def passed?
      conform_errors.empty?
    end
    alias conformed? passed?

    def descriptive_errors
      errors.map do |e|
        {
          description: e.message,
          pointer:     e.json_pointer
        }
      end
    end

    def error_message
      error_tree.map(&:message).join(", ")
    end

    def errors
      conform_errors.map(&:leaf_errors).flatten
    end

    def error_hash(i18n_namespace: nil)
      {}.tap do |error_hash|
        errors.each do |error|
          next if error.error_path.empty?

          message = error.translated_error(i18n_namespace)
          path_hash = error.error_path.reverse
                           .inject([message]) { |messages, key| { key => messages } }

          error_hash.deep_merge!(path_hash) do |_key, old, new|
            old + new if old.is_a?(Array) && new.is_a?(Array) # concat arrays during deep_merge
          end
        end
      end
    end

    def error_tree
      conform_errors
    end

    private

    attr_accessor :conform_errors
  end
end
