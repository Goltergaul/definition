# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "dry-struct", "~> 1.4"
  gem "awesome_print"
  gem "benchmark-ips"
  gem "pry"
  gem "ruby-prof"
  gem "definition", path: File.expand_path("../.", __dir__)
end

class DryStructModel < Dry::Struct
  schema schema.strict

  attribute :id, Dry::Types["strict.integer"]
  attribute :app_key, Dry::Types["strict.string"]
  attribute :app_version, Dry::Types["strict.string"]
  attribute :app_name, Dry::Types["strict.string"].optional.default(nil)
  attribute :app_branch, Dry::Types["strict.string"].optional.default(nil)
  attribute :platform, Dry::Types["strict.string"].optional.default(nil)
end

class DefinitionModel < Definition::Model
  required :id, Definition.Type(Integer)
  required :app_key, Definition.Type(String)
  required :app_version, Definition.Type(String)
  optional :app_name, Definition.Type(String)
  optional :app_branch, Definition.Type(String)
  optional :platform, Definition.Type(String)
end

puts "Benchmark with valid input data:"
valid_data = { id: 1, app_key: "com.test", app_version: "1.0.0", app_name: "testapp" }

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionModel.new(**valid_data)
  end

  x.report("dry-struct") do
    DryStructModel.new(**valid_data)
  end

  x.compare!
end

puts "Benchmark with invalid input data:"
valid_data = { id: "abc", app_key: "com.test", app_name: "testapp" }
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionModel.new(**valid_data)
  rescue StandardError
    Definition::InvalidModelError
  end

  x.report("dry-struct") do
    DryStructModel.new(**valid_data)
  rescue StandardError
    Dry::Struct::Error
  end

  x.compare!
end
