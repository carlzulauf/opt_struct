describe "OptStruct class usage spec" do
  context "two arguments and defaults" do
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

  context "argument with a matching default" do
    subject do
      OptStruct.new(:one, one: "foo")
    end

    it "causes the argument to not be required" do
      expect(subject.new.one).to eq("foo")
    end
  end

  context "wtih more complex test struct" do
    class TestStruct < OptStruct.new(foo: "bar")
      required :yin
      option :bar, default: "foo"
    end

    subject { TestStruct.new(yin: "yang") }

    it "throws argument error when missing required key" do
      expect { TestStruct.new }.to raise_error(ArgumentError)
    end

    it "uses default passed to .new" do
      expect(subject.foo).to eq("bar")
    end

    it "sets up option accessors for required keys" do
      expect(subject.yin).to eq("yang")
      subject.yin = "foo"
      expect(subject.options[:yin]).to eq("foo")
    end

    it "uses :default for key passed to .option" do
      expect(subject.bar).to eq("foo")
    end
  end
end
