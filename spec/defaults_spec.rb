class DefaultSymbolMethodExists < OptStruct.new
  option :foo, default: :bar

  def bar
    "test"
  end
end

class DefaultSymbolMethodDoesNotExist < OptStruct.new
  option :foo, default: :bar
end

class DefaultProc < OptStruct.new
  option :foo, default: -> { "bar" }
end

class DefaultLambda < OptStruct.new
  option :foo, default: lambda { "bar" }
end

class DefaultProcAndSymbolUsingOptions < OptStruct.new
  options foo: :bar, yin: -> { "yang" }

  def bar
    "test"
  end
end

class DefaultProcWithInstanceReference < OptStruct.new
  option :foo, default: -> { a_method }

  def a_method
    "bar"
  end
end

class DefaultProcWithChangingDefault < OptStruct.new
  @@id = 1

  option :foo, default: -> { auto_id }

  def auto_id
    @@id += 1
  end
end

describe "OptStruct default values" do
  describe "using a symbol" do
    it "defaults to method return value when method exists" do
      expect(DefaultSymbolMethodExists.new.foo).to eq("test")
      expect(DefaultSymbolMethodExists.new.options[:foo]).to eq("test")
    end

    it "defaults to symbol if method does not exist" do
      expect(DefaultSymbolMethodDoesNotExist.new.foo).to eq(:bar)
      expect(DefaultSymbolMethodDoesNotExist.new.options[:foo]).to eq(:bar)
    end
  end

  describe "using a proc" do
    it "calls the proc" do
      expect(DefaultProc.new.foo).to eq("bar")
      expect(DefaultProc.new.options[:foo]).to eq("bar")
    end

    it "executes in the context of the instance object" do
      expect(DefaultProcWithInstanceReference.new.foo).to eq("bar")
      expect(DefaultProcWithInstanceReference.new.options[:foo]).to eq("bar")
    end

    it "freshly evaluates for every instance" do
      expect(DefaultProcWithChangingDefault.new.foo).to eq(2)
      expect(DefaultProcWithChangingDefault.new.options[:foo]).to eq(3)
      expect(DefaultProcWithChangingDefault.new.foo).to eq(4)
    end

    it "evaluates only once per instance" do
      instance = DefaultProcWithChangingDefault.new
      value = instance.foo
      expect(instance.foo).to eq(value)
      expect(instance.fetch(:foo)).to eq(value)
      expect(instance.options[:foo]).to eq(value)
    end
  end

  describe "using a lambda" do
    it "calls the lambda" do
      expect(DefaultLambda.new.foo).to eq("bar")
      expect(DefaultLambda.new.fetch(:foo)).to eq("bar")
    end
  end

  describe "using options syntax" do
    it "evaluates a proc" do
      expect(DefaultProcAndSymbolUsingOptions.new.yin).to eq("yang")
      expect(DefaultProcAndSymbolUsingOptions.new.options[:yin]).to eq("yang")
    end

    it "evaluates a method via symbol" do
      expect(DefaultProcAndSymbolUsingOptions.new.foo).to eq("test")
      expect(DefaultProcAndSymbolUsingOptions.new.options[:foo]).to eq("test")
    end
  end
end
