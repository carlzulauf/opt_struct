# Spec for confirming compatibility with ruby 3.0+'s Ractor concurrency model

class RactorableStruct < OptStruct.new(:positional1, param1: "default1")
  option :param2
  # option :param3, default: -> { "default3" }
  options param4: "default4", param5: "default5"

  def param_concat
    # [param1, param2, param3, param4, param5].join(",")
    [param1, param2, param4, param5].join(",")
  end
end

# only run if Ractor support is detected
if defined?(Ractor)
  describe "OptStruct within Ractor usage" do
    it "allows struct to be initialized within a ractor" do
      ractor = Ractor.new { Ractor.yield RactorableStruct.new("test").param1 }
      expect(ractor.take).to eq("default1")
    end
  end
end
