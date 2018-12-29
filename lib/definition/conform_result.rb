# frozen_string_literal: true

module Definition
  class ConformResult
    def initialize(result, errors: [])
      self.result = result
      self.errors = errors
    end

    attr_accessor :result, :errors

    def passed?
      errors.empty?
    end

    def error_message
      errors.map(&:message).join(", ")
    end
  end
end
