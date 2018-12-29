require "spec_helper"

describe "Definition.Each" do
  subject(:definition) do
    Definition.Each(Definition::Type(Integer))
  end

  it_behaves_like "it conforms", [1,345,-4]

  context "with float value" do
    let(:value) { [1,-2,1.0,"foo",5] }

   it_behaves_like "it does not conform"
  end

  context "with hash value" do
    let(:value) { { a: 1} }

   it_behaves_like "it does not conform"
  end

  context "with range value" do
    let(:value) { (1..2) }

   it_behaves_like "it does not conform"
  end
end
