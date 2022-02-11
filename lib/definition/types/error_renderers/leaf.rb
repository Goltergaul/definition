# frozen_string_literal: true

require "definition/types/error_renderers/standard"

module Definition
  module Types
    module ErrorRenderers
      class Leaf < Standard
        def translated_error(_namespace = "definition")
          # When there are no sub errors, proceeding gets us into an infinite loop.
          return i18n_error if conform_error.sub_errors.empty?

          conform_error.leaf_errors.map(&:translated_error).join(", ")
        end
      end
    end
  end
end
