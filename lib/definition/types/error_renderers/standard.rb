# frozen_string_literal: true

module Definition
  module Types
    module ErrorRenderers
      class Standard
        def initialize(conform_error, i18n_namespace:)
          self.conform_error = conform_error
          self.i18n_namespace = i18n_namespace
        end

        def translated_error
          i18n_error
        end

        private

        def i18n_error
          ::I18n.t("#{i18n_namespace}.#{conform_error.i18n_key}",
                   **i18n_vars)
        end

        def i18n_vars
          conform_error.definition.context.merge(
            conform_error.i18n_context
          ).tap do |vars|
            vars[:default] = default if default
          end
        end

        def default
          nil
        end

        attr_accessor :conform_error, :i18n_namespace
      end
    end
  end
end
