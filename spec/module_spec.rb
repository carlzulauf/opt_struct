describe "OptStruct module usage" do
  context "required keyword" do
    class WithRequiredKeyword
      include OptStruct
      required :foo
    end

    it "raises an ArgumentError when missing" do
      expect{ WithRequiredKeyword.new }.to raise_error(ArgumentError)
    end

    it "initializes and provides an accessor when satisfied" do
      value = WithRequiredKeyword.new(foo: "bar")
      expect(value.foo).to eq("bar")
    end
  end

  context ".build options" do
    class WithBuildOptions
      include OptStruct.build(:foo, bar: nil)
    end

    it "raises an ArgumentError when required argument is missing" do
      expect{ WithBuildOptions.new }.to raise_error(ArgumentError)
    end

    it "provides accessors for arguments and keywords" do
      value = WithBuildOptions.new("something", bar: "foo")
      expect(value.foo).to eq("something")
      expect(value.bar).to eq("foo")
    end
  end
end
