# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "dry-initializer", "~> 3.1"
  gem "dry-types", "~> 1.5"
  gem "awesome_print"
  gem "benchmark-ips"
  gem "pry"
  gem "ruby-prof"
  gem "sorbet"
  gem "sorbet-runtime"
  gem "definition", path: File.expand_path("../.", __dir__)
end

class SorbetUseCase
  extend T::Sig

  sig { params(phone: String, admin: T::Boolean).void }
  def initialize(phone:, admin: false)
    self.phone = phone
    self.admin = admin
  end

  private

  attr_accessor :phone, :admin
end

class DryUseCase
  extend Dry::Initializer

  option :phone, Dry::Types["strict.string"]
  option :admin, Dry::Types["strict.bool"], default: false, optional: true
end

class DefinitionUseCase
  include Definition::Initializer

  required :phone, Definition.Type(String)
  optional :admin, Definition.Boolean, default: false
end

puts "Benchmark with valid input data:"
valid_data = { phone: "+49 3424 234234" }

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("sorbet") do
    SorbetUseCase.new(**valid_data)
  end

  x.report("definition") do
    DefinitionUseCase.new(**valid_data)
  end

  x.report("dry-struct") do
    DryUseCase.new(**valid_data)
  end

  x.compare!
end

puts "Benchmark with invalid input data:"
invalid_data = { phone: "+49 3424 234234", admin: "yes" }
Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("sorbet") do
    SorbetUseCase.new(**invalid_data)
  end

  x.report("definition") do
    DefinitionUseCase.new(**invalid_data)
  rescue Definition::Initializer::InvalidArgumentError
    nil
  end

  x.report("dry-struct") do
    DryUseCase.new(**invalid_data)
  rescue Dry::Types::ConstraintError
    nil
  end

  x.compare!
end
