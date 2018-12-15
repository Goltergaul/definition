module Definition
  class ConformResult
    def initialize(result, errors: [])
      self.result, self.errors = result, errors
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
