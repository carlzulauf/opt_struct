describe "OptStruct class usage spec" do
  context "nothing required" do
    subject do
      OptStruct.new(:one, :two, foo: "bar")
    end

    it "is initializable with nothing" do
      value = subject.new
      expect(value.foo).to eq("bar")
      expect(value.one).to eq(nil)
    end
  end
end
