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
    it "has the features defined in module" do
      a = AmazingConfigStruct.new(1, 2)
      expect([a.foo, a.bar]).to eq([1, 2])

      b = AmazingConfigStruct.new(foo: 1, bar: 2, x: 3)
      expect([b.foo, b.bar, b.x]).to eq([1, 2, 3])
    end

    it "has the features defiend in class" do
      a = AmazingConfigStruct.new(1, 2, yin: 3)
      expect(a.yin).to eq(3)
    end
  end
end
