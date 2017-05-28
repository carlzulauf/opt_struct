describe "OptStruct module usage" do
  class WithRequiredKeyword
    include OptStruct
    required :foo
  end

  it "raises an ArgumentError when required keyword is missing" do
    expect{ WithRequiredKeyword.new }.to raise_error(ArgumentError)
  end

  it "initializes and provides an accessor when required keywords satisfied" do
    value = WithRequiredKeyword.new(foo: "bar")
    expect(value.foo).to eq("bar")
  end
end
