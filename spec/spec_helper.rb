# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "pry"
require "definition"
require "awesome_print"
require "rspec/its"
require "approvals/rspec"

Dir[File.expand_path("../support/**/*rb", __FILE__)].each do |support_file|
  require support_file
end

RSpec.configure do |config|
  config.approvals_path = "spec/approvals/"
end
