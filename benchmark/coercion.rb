# frozen_string_literal: true

require "awesome_print"
require "benchmark/ips"
require "dry-validation"
require "pry"

lib = File.expand_path("../../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "./lib/definition"

UserSchema = Dry::Validation.Form do
  configure { config.type_specs = true }
  required(:age, :int).filled(:int?)
end

StringToInteger = lambda do |value|
  begin
    Integer(value)
  rescue
    value
  end
end
StringIntegerType = Definition::Types::Type.new(:integer,
                                                Integer,
                                                coerce: StringToInteger)
UserDefinition = Definition::Types::Keys.new(
  :user,
  req: {
    age: StringIntegerType
  }
)

ap "valid data:"
valid_data = {
  age: 18
}
ap UserDefinition.conform(valid_data)
ap UserSchema.call(valid_data).inspect

ap "coercible data:"
coercible_data = {
  age: "18"
}

ap UserDefinition.conform(coercible_data)
ap UserSchema.call(coercible_data).inspect

ap "invalid data:"
invalid_data = {
  age: "foo"
}

ap UserDefinition.explain(invalid_data)
ap UserSchema.call(invalid_data).inspect

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("valid definition") do
    UserDefinition.conform(valid_data)
  end

  x.report("valid dry-validation") do
    UserSchema.call(valid_data)
  end

  x.report("coercible definition") do
    UserDefinition.conform(coercible_data)
  end

  x.report("coercible dry-validation") do
    UserSchema.call(coercible_data)
  end

  x.report("invalid definition") do
    UserDefinition.conform(invalid_data)
  end

  x.report("invalid dry-validation") do
    UserSchema.call(invalid_data)
  end

  x.compare!
end
