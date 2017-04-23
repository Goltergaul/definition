shared_examples "it explains" do
  subject(:explain) { definition.explain(value) }
  it { verify { explain } }
end
