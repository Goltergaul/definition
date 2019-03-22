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
    Time.at(value / 1000.0).utc
  else
    value
  end
end
DrySchema = Dry::Validation.Params do # rubocop:disable Metrics/BlockLength
  configure do
    config.type_specs = true
  end

  required(:data).schema do
    required(:type, :string).value(Dry::Types["strict.string"].enum("article"))
    required(:id, :string).value(type?: String)
    required(:attributes).schema do
      required(:title, :string).filled(max_size?: 1000)
      required(:body, :string).filled(max_size?: 1000)
      required(:publish_date, DryTimeCoercionType).value(type?: Time)
    end

    required(:relationships).schema do
      required(:author).schema do
        required(:data).schema do
          required(:id, :string).value(type?: String)
          required(:type, :string).value(Dry::Types["strict.string"].enum("people"))
        end
      end
      optional(:comments).schema do
        required(:data).each do
          schema do
            required(:id, :string).value(type?: String)
            required(:type, :string).value(Dry::Types["strict.string"].enum("comment"))
          end
        end
      end
    end
  end
end

MAX_LENGTH = Definition.Lambda(:max_length) do |value|
  conform_with(value) if value.size <= 1000
end
MAX_STRING_LENGTH = Definition.And(
  Definition.Type(String),
  Definition.MaxSize(1000)
)
MILLISECONDS_TIME = Definition.Lambda(:milliseconds_time) do |v|
  conform_with(Time.at(v / 1000.0).utc) if v.is_a?(Integer)
end
DefinitionSchema = Definition.Keys do
  required(:data, Definition.Keys do
    required :type, Definition.Enum("article")
    required :id, Definition.Type(String)
    required(:attributes, Definition.Keys do
      required :title, MAX_STRING_LENGTH
      required :body, MAX_STRING_LENGTH
      required :publish_date, MILLISECONDS_TIME
    end)

    required(:relationships, Definition.Keys do
      required(:author, Definition.Keys do
        required(:data, Definition.Keys do
          required :id, Definition.Type(String)
          required :type, Definition.Enum("people")
        end)
      end)
      optional(:comments, Definition.Keys do
        required(:data, Definition.Each(
                          Definition.Keys do
                            required :id, Definition.Type(String)
                            required :type, Definition.Enum("comment")
                          end
                        ))
      end)
    end)
  end)
end

puts "Benchmark with valid input data:"
valid_data = {
  "data": {
    "type":          "article",
    "id":            "1",
    "attributes":    {
      "title":        "JSON:API paints my bikeshed!",
      "body":         "The shortest article. Ever.",
      "publish_date": Time.utc(2018).to_i * 1000
    },
    "relationships": {
      "author":   {
        "data": { "id": "42", "type": "people" }
      },
      "comments": {
        "data": [
          { "id": "1", "type": "comment" },
          { "id": "2", "type": "comment" }
        ]
      }
    }
  }
}
ap DefinitionSchema.conform(valid_data).value
ap DrySchema.call(valid_data)
raise unless DefinitionSchema.conform(valid_data).passed?
raise unless DrySchema.call(valid_data).success?

Benchmark.ips do |x|
  x.config(time: 5, warmup: 2)

  x.report("definition") do
    DefinitionSchema.conform(valid_data)
  end

  x.report("dry-validation") do
    DrySchema.call(valid_data)
  end

  x.compare!
end

puts "Benchmark with invalid input data:"
invalid_data = {
  "data": {
    "type":          "article",
    "id":            "1",
    "attributes":    {
      "title":        "JSON:API paints my bikeshed!",
      "body":         "The shortest article. Ever.",
      "publish_date": Time.utc(2018).to_s
    },
    "relationships": {
      "author":   {
        "data": { "id": "42", "type": "people" }
      },
      "comments": {
        "data": [
          { "id": "1", "type": "comment" },
          { "id": "2", "type": "post" }
        ]
      }
    }
  }
}
ap DefinitionSchema.conform(invalid_data).error_message
ap DrySchema.call(invalid_data).errors
raise if DefinitionSchema.conform(invalid_data).passed?
raise if DrySchema.call(invalid_data).success?

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
