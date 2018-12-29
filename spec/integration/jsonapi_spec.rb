require "spec_helper"

describe "Definition.Keys" do
  subject(:definition) do
    Definition.Keys do
      required(:data, Definition.Keys do
        required :type, Definition.Type(String)
        required :id, Definition.Type(String)
        required(:attributes, Definition.Keys do
          required :title, Definition.And(
            Definition.Type(String),
            Definition.MaxSize(256)
          )
          required :body, Definition.And(
            Definition.Type(String),
            Definition.MaxSize(64_000)
          )
          required(:publish_date, Definition.Lambda(:milliseconds_time) do |v|
            Time.at(v/1000.0).utc
          end)
        end)

        required(:relationships, Definition.Keys do
          required(:author, Definition.Keys do
            required(:data, Definition.Keys do
              required :id, Definition.Type(String)
              required :type, Definition.Enum("people")
            end)
          end)
        end)
      end)
    end
  end

  #it_behaves_like "it conforms via coersion",
  #  input: {
  #    "data": {
  #      "type": "articles",
  #      "id": "1",
  #      "attributes": {
  #        "title": "JSON:API paints my bikeshed!",
  #        "body": "The shortest article. Ever.",
  #        "publish_date": Time.utc(2018).to_i*1000
  #      },
  #      "relationships": {
  #        "author": {
  #          "data": {"id": "42", "type": "people"}
  #        }
  #      }
  #    }
  #  },
  #  output: {
  #    "data": {
  #      "type": "articles",
  #      "id": "1",
  #      "attributes": {
  #        "title": "JSON:API paints my bikeshed!",
  #        "body": "The shortest article. Ever.",
  #        "publish_date": Time.utc(2018)
  #      },
  #      "relationships": {
  #        "author": {
  #          "data": {"id": "42", "type": "people"}
  #        }
  #      }
  #    }
	#  }
end
