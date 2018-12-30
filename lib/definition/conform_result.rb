# frozen_string_literal: true

module Definition
  class ConformResult
    def initialize(value, errors: [])
      self.value = value
      self.errors = errors
    end

    attr_accessor :value, :errors

    def passed?
      errors.empty?
    end

    def error_message
      errors.map(&:message).join(", ")
    end
  end
end
