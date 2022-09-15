# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "dry-validation", "~> 1.8"
  gem "dry-types", "~> 1.5"
  gem "awesome_print"
  gem "benchmark-ips"
  gem "definition", path: File.expand_path("../.", __dir__)
end

class DryContract < Dry::Validation::Contract
  params do
    required(:name).filled(:string)
    required(:time).filled(:time)
  end
end
DryContractInstance = DryContract.new

DefinitionSchema = Definition.Keys do
  required(:name, Definition.Type(String))
  required(:time, Definition.Type(Time))
end

puts "Benchmark with valid input data:"
valid_data = { name: "test", time: Time.now }
ap DefinitionSchema.conform(valid_data).value
ap DryContractInstance.call(valid_data)
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionSchema.conform(valid_data)
  end

  x.report("dry-validation") do
    DryContractInstance.call(valid_data)
  end

  x.compare!
end

puts "Benchmark with invalid input data:"
invalid_data = { name: 1, time: Time.now.to_s }
ap DefinitionSchema.conform(invalid_data).error_message
ap DryContractInstance.call(invalid_data).errors
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionSchema.conform(invalid_data)
  end

  x.report("dry-validation") do
    DryContractInstance.call(invalid_data)
  end

  x.compare!
end
