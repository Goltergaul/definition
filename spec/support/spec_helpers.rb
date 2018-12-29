module SpecHelpers
  def failing_definition(value, error_message)
    double(:definition, conform: Definition::ConformResult.new(value, errors: [
      double(:conform_error, message: error_message)
    ]))
  end

  def conforming_definition(value)
    double(:definition, conform: Definition::ConformResult.new(value))
  end
end
