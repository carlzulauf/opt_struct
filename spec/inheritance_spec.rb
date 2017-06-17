class ParentClassStruct < OptStruct.new
  options :yin, :yang
end

class WithMoreOptions < ParentClassStruct
  options :x, :y
end

class WithEvenMoreOptions < WithMoreOptions
  options :a, :b
end

class WithNewDefaults < ParentClassStruct
  option :yin, default: "foo"
  options yang: "bar"
end

class ParentModuleStruct
  include OptStruct
  options :yin, :yang
end

class MWithMoreOptions < ParentModuleStruct
  options :x, :y
end
class MWithNewDefaults < ParentModuleStruct
  option :yin, default: "foo"
  options yang: "bar"
end

module AmazingConfigBehavior
  include OptStruct.build(:foo, :bar)
  option :x
end

class AmazingConfigStruct
  include AmazingConfigBehavior
  options yin: :yang
end

class AmazingPrependStruct
  prepend AmazingConfigBehavior
  options yin: :yang
end

module BehaviorWithIncluded
  include OptStruct
  options x: 0, y: 0

  def self.included(klass)
    klass.instance_variable_set(:@triggered, true)
  end
end

class StructWithIncluded
  include BehaviorWithIncluded

  options foo: "bar"

  def self.triggered?
    @triggered
  end
end

describe "inheritance" do
  context "with more options" do
    subject { WithMoreOptions }

    it "has the features of the parent" do
      a = subject.new(yin: 1, yang: 2)
      expect([a.yin, a.yang]).to eq([1, 2])
    end

    it "has the features of the child" do
      a = subject.new(x: 1, y: 2)
      expect([a.x, a.y]).to eq([1, 2])
    end
  end

  context "with even more options" do
    subject { WithEvenMoreOptions }
    let(:parent) { WithMoreOptions }

    it "has the features of the parent" do
      expect(subject.new(x: 1).x).to eq(1)
    end

    it "doesn't add features to the parent" do
      expect { parent.new.a }.to raise_error(NoMethodError)
    end

    it "has features to the child" do
      expect(subject.new(a: 1).a).to eq(1)
    end
  end

  context "with new defaults" do
    subject { WithNewDefaults }

    it "has the features of the parent" do
      a = subject.new(yin: 1, yang: 2)
      expect([a.yin, a.yang]).to eq([1, 2])
    end

    it "has the features of the child" do
      a = subject.new
      expect([a.yin, a.yang]).to eq(%w{foo bar})
    end
  end

  context "build with more options" do
    subject { MWithMoreOptions }

    it "has the features of the parent" do
      a = subject.new(yin: 1, yang: 2)
      expect([a.yin, a.yang]).to eq([1, 2])
    end

    it "has the features of the child" do
      a = subject.new(x: 1, y: 2)
      expect([a.x, a.y]).to eq([1, 2])
    end
  end

  context "build with new defaults" do
    subject { MWithNewDefaults }

    it "has the features of the parent" do
      a = subject.new(yin: 1, yang: 2)
      expect([a.yin, a.yang]).to eq([1, 2])
    end

    it "has the features of the child" do
      a = subject.new
      expect([a.yin, a.yang]).to eq(%w{foo bar})
    end
  end

  context "module in module" do
    subject { AmazingConfigStruct }
    it "has the features defined in module" do
      a = subject.new(1, 2)
      expect([a.foo, a.bar]).to eq([1, 2])

      b = subject.new(foo: 1, bar: 2, x: 3)
      expect([b.foo, b.bar, b.x]).to eq([1, 2, 3])
    end

    it "has the features defiend in class" do
      a = subject.new(1, 2, yin: 3)
      expect(a.yin).to eq(3)
    end
  end

  context "module in module, prepended" do
    subject { AmazingPrependStruct }
    it "has the features defined in module" do
      a = subject.new(1, 2)
      expect([a.foo, a.bar]).to eq([1, 2])

      b = subject.new(foo: 1, bar: 2, x: 3)
      expect([b.foo, b.bar, b.x]).to eq([1, 2, 3])
    end

    it "has the features defiend in class" do
      a = subject.new(1, 2, yin: 3)
      expect(a.yin).to eq(3)
    end
  end

  context "module with included" do
    subject { StructWithIncluded }

    it "triggers the custom included behavior" do
      expect(subject.triggered?).to eq(true)
    end

    it "sets up the defaults correctly" do
      a = subject.new
      expect([a.x, a.y, a.foo]).to eq([0,0,"bar"])
    end
  end
end
