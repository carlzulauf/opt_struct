class DefaultSymbolMethodExists < OptStruct.new
  option :foo, default: :bar

  def bar
    "test"
  end
end

class DefaultSymbolMethodPrivate < OptStruct.new
  option :foo, default: :bar

  private

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

class OptionsWithNilDefaults < OptStruct.new
  option :implicit_nil
  option :explicit_nil, nil
  option :nil_block, -> { nil }
  option :nil_method, :returns_nil
  options :opt_list1, :opt_list2, opt_list_nil: nil

  def returns_nil
    nil
  end
end

describe "OptStruct default values" do
  describe "using a symbol" do
    it "defaults to method return value when method exists" do
      expect(DefaultSymbolMethodExists.new.foo).to eq("test")
      expect(DefaultSymbolMethodExists.new.options[:foo]).to eq("test")
    end

    it "defaults to method return value when method is private" do
      expect(DefaultSymbolMethodPrivate.new.foo).to eq("test")
      expect(DefaultSymbolMethodPrivate.new.options[:foo]).to eq("test")
    end

    it "defaults to symbol if method does not exist" do
      expect(DefaultSymbolMethodDoesNotExist.new.foo).to eq(:bar)
      expect(DefaultSymbolMethodDoesNotExist.new.options[:foo]).to eq(:bar)
    end

    context "matching a method with nil return value" do
      it "initializes the option with a nil value" do
        expect(OptionsWithNilDefaults.new.nil_method).to eq(nil)
        expect(OptionsWithNilDefaults.new.options.key?(:nil_method)).to eq(true)
      end
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

    context "with a nil return value" do
      it "initializes the option with nil" do
        expect(OptionsWithNilDefaults.new.nil_block).to eq(nil)
        expect(OptionsWithNilDefaults.new.options.key?(:nil_block)).to eq(true)
      end
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

    it "initializes values with nil defaults" do
      expect(OptionsWithNilDefaults.new.opt_list_nil).to eq(nil)
      expect(OptionsWithNilDefaults.new.options.key?(:opt_list_nil)).to eq(true)
    end

    it "does not initialize values with no default provided" do
      expect(OptionsWithNilDefaults.new.opt_list1).to eq(nil)
      expect(OptionsWithNilDefaults.new.opt_list2).to eq(nil)
      expect(OptionsWithNilDefaults.new.options.key?(:opt_list1)).to eq(false)
      expect(OptionsWithNilDefaults.new.options.key?(:opt_list2)).to eq(false)
    end
  end

  describe "using option syntax" do
    context "with no explicit default" do
      it "returns nil from option accessor" do
        expect(OptionsWithNilDefaults.new.implicit_nil).to eq(nil)
      end

      it "does not initialize the option in the options hash" do
        expect(OptionsWithNilDefaults.new.options.key?(:implicit_nil)).to eq(false)
      end
    end

    context "with explicit default nil as second argument" do
      it "returns nil from the option accessor" do
        expect(OptionsWithNilDefaults.new.explicit_nil).to eq(nil)
      end

      it "initializes the option in the options hash" do
        expect(OptionsWithNilDefaults.new.options.key?(:explicit_nil)).to eq(true)
      end
    end
  end
end
