require "spec_helper"

describe "Definition.Type" do
  subject(:definition) do
    Definition.Type(Float)
  end

  it_behaves_like "it conforms", 9.99

  context "with string" do
   let(:value) { "9.99" }

   it_behaves_like "it does not conform"
  end
end
