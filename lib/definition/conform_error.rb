# frozen_string_literal: true

require "i18n"

module Definition
  class ConformError
    def initialize(definition, message, sub_errors: [], **options)
      self.definition = definition
      self.message = message
      self.sub_errors = sub_errors
      self.i18n_key = options.fetch(:i18n_key, definition.name)
      self.i18n_context = options.fetch(:i18n_context, {})
      self.translated_error = options.fetch(:translated_message, nil)
      assign_parents
    end

    attr_accessor :definition, :sub_errors, :parent, :i18n_key, :i18n_context
    attr_writer :message, :translated_error

    def message
      if sub_errors.empty?
        @message
      else
        "#{@message}: { " + sub_errors.map(&:message).join(", ") + " }"
      end
    end

    def to_s
      "<Definition::ConformError \n\t message: \"#{message}\", \n\t json_pointer: \"#{json_pointer}\">"
    end

    alias inspect to_s

    def error_path
      current = self
      path = current.is_a?(KeyConformError) ? [key] : []
      while (current = current.parent)
        next unless current.is_a?(KeyConformError)

        path += [current.key]
      end
      path.reverse
    end

    def json_pointer
      "/#{error_path.join('/')}"
    end

    def leaf_errors
      return [self] if sub_errors.empty?

      sub_errors.map(&:leaf_errors).flatten
    end

    def translated_error(namespace = "definition")
      @translated_error ||= definition.error_renderer.new(self, i18n_namespace: namespace).translated_error
    end

    private

    def assign_parents
      sub_errors.each do |error|
        error.parent = self
      end
    end
  end
end
