# Spec for confirming compatibility with ruby 3.0+'s Ractor concurrency model

class RactorableStruct < OptStruct.new(:positional1, param1: "default1".freeze)
  shareable!
  required :required1
  option :param2
  option :param3, default: -> { "default3" }
  options param4: "default4", param5: "default5"

  def cat
    [positional1, required1, param1, param2, param3, param4, param5].join(",")
  end
end

class RactorBuilder
  include OptStruct.build(:foo, bar: nil)
  shareable!
  option :yin, default: -> { "yang" }

  def cat
    [foo, bar, yin].join(",")
  end
end

RactorBlock = OptStruct.new do
  shareable!
  required :attr1
  option :attr2, default: -> { "block" }
  options attr3: "is", attr4: "working"

  def cat
    [attr1, attr2, attr3, attr4].join(",")
  end

end

# only run if Ractor support is detected
if defined?(Ractor)
  describe "OptStruct within Ractor usage" do
    let(:struct_ractor) do
      Ractor.new do
        Ractor.yield RactorableStruct.new("test", required1: "value1").cat
      end
    end

    let(:build_ractor) do
      Ractor.new do
        Ractor.yield RactorBuilder.new("builder", bar: "is", yin: "working").cat
      end
    end

    let(:block_ractor) do
      Ractor.new do
        Ractor.yield RactorBlock.new(attr1: "ractor").cat
      end
    end

    it "allows struct to be initialized within a ractor" do
      expect(struct_ractor.take).to eq(
        "test,value1,default1,,default3,default4,default5"
      )
    end

    it "allows mixin-based struct to be initialized within a ractor" do
      expect(build_ractor.take).to eq("builder,is,working")
    end

    it "allows block-based struct to be initialized within a ractor" do
      expect(block_ractor.take).to eq("ractor,block,is,working")
    end

    it "allows struct to be initialized within multiple ractors" do
      ractors = [
        Ractor.new { Ractor.yield RactorBlock.new(attr1: "ractor1", attr2: "multi-use").cat },
        Ractor.new { Ractor.yield RactorBlock.new(attr1: "ractor2", attr2: "multi-use").cat },
      ]

      expect(ractors.map(&:take)).to eq([
        "ractor1,multi-use,is,working",
        "ractor2,multi-use,is,working"
      ])
    end
  end
end
