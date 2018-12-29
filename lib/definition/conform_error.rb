# frozen_string_literal: true

module Definition
  class ConformError
    def initialize(definition, message, sub_errors: [])
      self.definition = definition
      self.message = message
      self.sub_errors = sub_errors
    end

    attr_accessor :definition, :sub_errors
    attr_writer :message

    def message
      if sub_errors.empty?
        @message
      else
        "#{@message}: { " + sub_errors.map(&:message).join(", ") + " }"
      end
    end
  end
end
