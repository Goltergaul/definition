# frozen_string_literal: true

require "definition/types/error_renderers/standard"

module Definition
  module Types
    module ErrorRenderers
      class Lambda < Standard
        def default
          "Did not pass test for '#{conform_error.definition.name}'"
        end
      end
    end
  end
end
