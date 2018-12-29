require "spec_helper"

describe "Definition.Lambda" do
  subject(:definition) do
    Definition.Lambda(:email) do |value|
      conform_with(value) if value.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
    rescue NoMethodError
      value
    end
  end

  it_behaves_like "it conforms", "jon@doe.com"
  it_behaves_like "it conforms", "alice@example.cc"

  context "with invalid email address" do
   let(:value) { "alice@tmobile" }

   it_behaves_like "it does not conform"
  end

  context "with integer value" do
   let(:value) { 1 }

   it_behaves_like "it does not conform"
  end
end
