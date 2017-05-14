# frozen_string_literal: true

require "awesome_print"
require "benchmark/ips"
require "dry-validation"
require "pry"

lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "./lib/definition"

UserSchema = Dry::Validation.Schema do
  required(:name).filled
  required(:age).filled(:int?)
  required(:address).schema do
    required(:street).filled
    required(:city).filled
    required(:zipcode).filled
  end
end

StringType = Definition::Types::Type.new(:string, String)
IntegerType = Definition::Types::Type.new(:integer, Integer)
UserDefinition = Definition::Types::Keys.new(
  :user,
  req: {
    name:    StringType,
    age:     IntegerType,
    address: Definition::Types::Keys.new(
      :address,
      req: {
        street:  StringType,
        city:    StringType,
        zipcode: StringType
      }
    )
  }
)

valid_data = {
  name:    "michael",
  age:     18,
  address: {
    street:  "123 Fakestreet",
    city:    "Atlanta",
    zipcode: "1234"
  }
}
ap UserDefinition.conform(valid_data)
ap UserSchema.call(valid_data).inspect

invalid_data = {
  name:    "michael",
  age:     18,
  address: {
    street: "123 Fakestreet",
    city:   "Atlanta"
  }
}

ap UserDefinition.explain(invalid_data)
ap UserSchema.call(invalid_data).inspect

class GCSuite
  def warming(*)
    run_gc
  end

  def running(*)
    run_gc
  end

  def warmup_stats(*); end

  def add_report(*); end

  private

  def run_gc
    GC.enable
    GC.start
    GC.disable
  end
end

suite = GCSuite.new

Benchmark.ips do |x|
  x.config(suite: suite, time: 5, warmup: 2)
  x.iterations = 3

  x.report("valid definition") do
    UserDefinition.conform(valid_data)
  end

  x.report("valid dry-validation") do
    UserSchema.call(valid_data)
  end

  x.report("invalid definition") do
    UserDefinition.conform(invalid_data)
  end

  x.report("invalid dry-validation") do
    UserSchema.call(invalid_data)
  end

  x.compare!
end
