# frozen_string_literal: true

require "i18n"

module Definition
  class ConformError
    def initialize(definition, message, sub_errors: [], i18n_key: definition.name)
      self.definition = definition
      self.message = message
      self.sub_errors = sub_errors
      self.i18n_key = i18n_key
      assign_parents
    end

    attr_accessor :definition, :sub_errors, :parent, :i18n_key
    attr_writer :message

    def message
      if sub_errors.empty?
        @message
      else
        "#{@message}: { " + sub_errors.map(&:message).join(", ") + " }"
      end
    end

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

    def translated_error(namespace = "definition", vars: {})
      namespace ||= "definition"
      vars[:key] = key if respond_to?(:key)
      ::I18n.t("#{namespace}.#{i18n_key}", definition.context.merge!(vars))
    end

    private

    def assign_parents
      sub_errors.each do |error|
        error.parent = self
      end
    end
  end
end
