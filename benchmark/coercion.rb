# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  # FIXME: benchmark needs to be updated to work with dry-validation 1.0.0"
  gem "dry-validation", "< 1.0.0"
  gem "dry-types", "< 0.15"
  gem "awesome_print"
  gem "benchmark-ips"
  gem "pry"
  gem "definition", path: File.expand_path("../.", __dir__)
end

DryTimeCoercionType = Dry::Types["strict.string"].constructor do |value|
  if value.is_a?(Integer)
    Time.at(value).utc
  else
    value
  end
end
DrySchema = Dry::Validation.Params do
  configure do
    config.type_specs = true
  end

  required(:name, :string).value(type?: String)
  required(:time, DryTimeCoercionType).value(type?: Time)
end

DefinitionSchema = Definition.Keys do
  required(:name, Definition.Type(String))
  required(:time, Definition.Lambda(:time) do |value|
    conform_with(Time.at(value).utc) if value.is_a?(Integer)
  end)
end

puts "Benchmark with valid input data:"
valid_data = { name: "test", time: Time.now.to_i }
ap DefinitionSchema.conform(valid_data).value
ap DrySchema.call(valid_data)
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionSchema.conform(valid_data).value
  end

  x.report("dry-validation") do
    DrySchema.call(valid_data)
  end

  x.compare!
end

puts "Benchmark with invalid input data:"
invalid_data = { name: 1, time: Time.now.to_s }
ap DefinitionSchema.conform(invalid_data).error_message
ap DrySchema.call(invalid_data).errors
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionSchema.conform(invalid_data)
  end

  x.report("dry-validation") do
    DrySchema.call(invalid_data)
  end

  x.compare!
end
