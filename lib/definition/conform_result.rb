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

    def error_message
      error_tree.map(&:message).join(", ")
    end

    def leaf_errors
      conform_errors.map(&:leaf_errors).flatten
    end

    def errors
      leaf_errors.map do |error|
        find_next_parent_key_error(error) || error
      end.compact.uniq
    end

    def error_hash
      {}.tap do |error_hash|
        errors.each do |error|
          next if error.error_path.empty?

          path_hash = error.error_path.reverse
                           .inject([error]) { |errors, key| { key => errors } }

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

    def find_next_parent_key_error(error)
      current = error
      loop do
        return current if current.is_a?(KeyConformError)

        current = current.parent
        break unless current
      end
      nil
    end

    attr_accessor :conform_errors
  end
end
