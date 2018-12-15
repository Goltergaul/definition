module Definition
  class ConformError
    def initialize(definition, message, sub_errors: [])
      self.definition, self.message = definition, message
      self.sub_errors = sub_errors
    end

    attr_accessor :definition, :message, :sub_errors

    def message
      if sub_errors.empty?
        @message
      else
        "#{@message}: { " + sub_errors.map(&:message).join(", ") + " }"
      end
    end
  end
end
