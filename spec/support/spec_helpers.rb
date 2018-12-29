# frozen_string_literal: true

module SpecHelpers
  def failing_definition(value, error_message)
    instance_double(Definition::Types::Base,
                    conform: Definition::ConformResult.new(
                      value, errors: [instance_double(Definition::ConformError, message: error_message)]
                    ))
  end

  def conforming_definition(value)
    instance_double(Definition::Types::Base, conform: Definition::ConformResult.new(value))
  end
end
