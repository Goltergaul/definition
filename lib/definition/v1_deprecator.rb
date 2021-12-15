# frozen_string_literal: true

require "active_support/deprecation"

module Definition
  V1Deprecator = ActiveSupport::Deprecation.new("1.0", "Definition")
end
