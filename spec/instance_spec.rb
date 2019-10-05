describe "OptStruct instance methods usage" do
  InstanceableClass = OptStruct.new(:arity_arg) do
    required :required_arg
    option :optional_arg
    
    def arity_up
      options[:arity_arg].upcase
    end
    
    def required_up
      options[:required_arg].upcase
    end
    
    def optional_up
      options.fetch(:optional_arg, "default").upcase
    end
  end
  
  subject { InstanceableClass.new(arity_arg: "yaaa", required_arg: "yara") }
  
  it "allows use of #options to access required args" do
    expect(subject.required_up).to eq("YARA")
  end
  
  it "allows use of #options to access arity arguments" do
    expect(subject.arity_up).to eq("YAAA")
  end
  
  it "allows use of #options.fetch to provide default for optional args" do
    expect(subject.optional_up).to eq("DEFAULT")
  end
  
  context "with optional_arg supplied" do
    subject do
      InstanceableClass.new(
        arity_arg:    "yaaa",
        required_arg: "yara",
        optional_arg: "yaoa"
      )
    end
    
    it "allows use of #options.fetch to safely access optional arguments" do
      expect(subject.optional_up).to eq("YAOA")
    end
    
  end
end
