# frozen_string_literal: true

require "spec_helper"

describe Definition do
  it "has a version number" do
    expect(Definition::VERSION).not_to be nil
  end
end
