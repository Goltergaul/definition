# frozen_string_literal: true

require "definition/conform_error"

module Definition
  class KeyConformError < ConformError
    def initialize(definition, message, key:, sub_errors: [], i18n_key: definition.name)
      self.key = key
      super(definition, message, sub_errors: sub_errors, i18n_key: i18n_key)
    end

    attr_accessor :key

    def error_key_path
      path = [key]
      while (current = parent)
        next unless current.is_a?(KeyConformError)

        path += [current.key]
      end
      path.reverse
    end

    private

    def assign_parents
      sub_errors.each do |error|
        error.parent = self
      end
    end
  end
end
