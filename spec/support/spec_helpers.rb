# frozen_string_literal: true

module SpecHelpers
  def failing_definition(definition_name, translated_error_message: nil)
    Definition.Lambda(definition_name) do |_value|
      fail_with(translated_error_message) if translated_error_message
    end
  end

  def conforming_definition(conform_with: nil)
    Definition.Lambda(:conforming_def) do |real_value|
      conform_with(conform_with || real_value)
    end
  end
end
