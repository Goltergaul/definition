# frozen_string_literal: true

require "active_support"

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
          path_hash = if error.error_path.empty?
                        { "" => error }
                      else
                        error.error_path.reverse
                             .inject([error]) { |errors, key| { key => errors } }
                      end

          merge_error_hash(error_hash, path_hash)
        end
      end
    end

    def error_tree
      conform_errors
    end

    private

    def merge_error_hash(hash, new_hash)
      hash.deep_merge!(new_hash) do |_key, old, new|
        if old.is_a?(Array) && new.is_a?(Hash) # Dont replace Hashes with arrays
          new
        elsif old.is_a?(Array) && new.is_a?(Array) # concat arrays during deep_merge
          old + new
        end
      end
    end

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
