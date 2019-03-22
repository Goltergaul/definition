# frozen_string_literal: true

require "spec_helper"
require "i18n"

describe "JSONAPI body validation" do
  class JsonApiRequestHandler
    MILLISECONDS_TIME = Definition.Lambda(:milliseconds_time) do |v|
      conform_with(Time.at(v / 1000.0).utc) if v.is_a?(Integer)
    end

    BODY_SCHEMA = Definition.Keys do
      required(:data, Definition.Keys do
        required :type, Definition.Equal("article")
        required :id, Definition.Type(String)
        required(:attributes, Definition.Keys do
          required :title, Definition.MaxSize(1000)
          required :body, Definition.MaxSize(1000)
          required :publish_date, MILLISECONDS_TIME
        end)

        required(:relationships, Definition.Keys do
          required(:author, Definition.Keys do
            required(:data, Definition.Keys do
              required :id, Definition.Type(String)
              required :type, Definition.Equal("people")
            end)
          end)
          optional(:comments, Definition.Keys do
            required(:data, Definition.Each(
                              Definition.Keys do
                                required :id, Definition.Type(String)
                                required :type, Definition.Equal("comment")
                              end
            ))
          end)
        end)
      end)
    end

    def self.errors(request_body)
      result = BODY_SCHEMA.conform(request_body)
      result.errors.map do |e|
        {
          title:       "Validation error",
          description: e.translated_error,
          pointer:     e.json_pointer
        }
      end
    end
  end

  subject(:definition) { JsonApiRequestHandler::BODY_SCHEMA }

  it_behaves_like "it conforms via coersion",
                  input:  {
                    "data": {
                      "type":          "article",
                      "id":            "1",
                      "attributes":    {
                        "title":        "JSON:API paints my bikeshed!",
                        "body":         "The shortest article. Ever.",
                        "publish_date": Time.utc(2018).to_i * 1000
                      },
                      "relationships": {
                        "author": {
                          "data": { "id": "42", "type": "people" }
                        }
                      }
                    }
                  },
                  output: {
                    "data": {
                      "type":          "article",
                      "id":            "1",
                      "attributes":    {
                        "title":        "JSON:API paints my bikeshed!",
                        "body":         "The shortest article. Ever.",
                        "publish_date": Time.utc(2018)
                      },
                      "relationships": {
                        "author": {
                          "data": { "id": "42", "type": "people" }
                        }
                      }
                    }
                  }

  it_behaves_like "it conforms via coersion",
                  input:  {
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
                  },
                  output: {
                    "data": {
                      "type":          "article",
                      "id":            "1",
                      "attributes":    {
                        "title":        "JSON:API paints my bikeshed!",
                        "body":         "The shortest article. Ever.",
                        "publish_date": Time.utc(2018)
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

  context "with invalid body" do
    let(:value) do
      {
        "data": {
          "type":          "article",
          "id":            "1",
          "attributes":    {
            "title":        "JSON:API paints my bikeshed!",
            "body":         "a" * 2000,
            "publish_date": Time.utc(2018).to_s
          },
          "relationships": {
            "author":   {
              "data": { "id": "42", "type": "people" }
            },
            "comments": {
              "data": [
                { "id": "1", "type": "post" }
              ]
            }
          }
        }
      }
    end

    it_behaves_like "it does not conform"

    describe "translated errors" do
      it "renders errors" do
        errors = JsonApiRequestHandler.errors(value)
        verify(format: :json) { errors }
      end
    end
  end
end
