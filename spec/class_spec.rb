describe "OptStruct class usage spec" do
  context "nothing required" do
    subject do
      OptStruct.new(:one, :two, foo: "bar")
    end

    it "is initializable with only required args" do
      value = subject.new :foo, :bar
      expect(value.foo).to eq("bar")
      expect(value.one).to eq(:foo)
    end

    it "is not initializable without required args" do
      expect { subject.new }.to raise_error(ArgumentError)
    end

    it "can satisfy required args from a hash" do
      value = subject.new(one: "foo", two: "bar", foo: "oof")
      expect(value.one).to eq("foo")
      expect(value.two).to eq("bar")
      expect(value.options).to eq(foo: "oof")
    end

    it "allows options to be grabbed via fetch" do
      value = subject.new(one: "foo", two: "bar", foo: "oof")
      expect(value.fetch(:foo)).to eq("oof")
      expect{value.fetch(:bar)}.to raise_error(KeyError)
      expect{value.fetch(:one)}.to raise_error(KeyError)
      expect(value.fetch(:bar, :default)).to eq(:default)
      expect(value.fetch(:bar){:default}).to eq(:default)
    end
  end
end
