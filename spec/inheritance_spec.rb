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

class BaseClassWithInheritedHook
  def self.inherited(child)
    child.instance_variable_set(:@hook_ran, true)
    child.define_method(:hook_ran?) { self.class.instance_variable_get(:@hook_ran) }
  end
end

class ChildExpectingInheritedBehavior < BaseClassWithInheritedHook
  include OptStruct

  option :opt_structed, default: true

  def call
    hook_ran?
  end
end

class SubchildExpectingBehavior < ChildExpectingInheritedBehavior
  option :still_opt_structed, default: -> { :yes }
end

$breaker = true

class BaseClassWithInit
  include OptStruct

  option :opt1
  init { self.opt1 = :value1 }
end

class Child1WithInit < BaseClassWithInit
  option :opt2
  init { self.opt2 = :value2 }
end

class Child2WithInit < BaseClassWithInit
  option :opt3
  init { self.opt3 = :value3 }
end

describe "inheritance" do
  context "when inherited with stacking callbacks" do
    let(:parent) { BaseClassWithInit.new }
    let(:child1) { Child1WithInit.new }
    let(:child2) { Child2WithInit.new }

    it "parent only has opt1 and it's set" do
      expect(parent.opt1).to eq(:value1)
      expect(parent.respond_to?(:opt2)).to eq(false)
      expect(parent.respond_to?(:opt3)).to eq(false)
    end

    it "child1 has opt1 and opt2 present, but not opt3" do
      expect(child1.opt1).to eq(:value1)
      expect(child1.opt2).to eq(:value2)
      expect(child1.respond_to?(:opt3)).to eq(false)
    end

    it "child2 has opt1 and opt3 present, but not opt2" do
      expect(child2.opt1).to eq(:value1)
      expect(child2.respond_to?(:opt2)).to eq(false)
      expect(child2.opt3).to eq(:value3)
    end
  end
  context "when included in a class expecting inherited behavior from parent" do
    let(:parent) { BaseClassWithInheritedHook }
    let(:child) { SubchildExpectingBehavior }

    subject { child.new }

    it "doesn't break the existing inherited behavior" do
      expect(subject.()).to eq(true)
    end

    it "continues to behave like an opt struct" do
      expect(subject.opt_structed).to eq(true)
      expect(subject.still_opt_structed).to eq(:yes)
    end
  end

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
