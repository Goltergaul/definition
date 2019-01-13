# frozen_string_literal: true

require "definition/version"
require "definition/dsl"
require "definition/dsl/comparators"
require "definition/dsl/nil"
require "definition/value_object"

module Definition
  extend Dsl
  extend Dsl::Comparators
  extend Dsl::Nil
end
