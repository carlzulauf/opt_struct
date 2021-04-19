describe "OptStruct instance methods usage" do
  InstanceableClass = OptStruct.new(:arity_arg) do
    option :required_arg, required: true
    option :optional_arg

    option :private_arg, private: true, default: "yas"
    required :private_required_arg, private: true

    def arity_up
      options[:arity_arg].upcase
    end

    def required_up
      options[:required_arg].upcase
    end

    def optional_up
      (options[:optional_arg] || "default").upcase
    end

    def private_up
      private_arg.upcase
    end
  end

  subject { InstanceableClass.new(arity_arg: "yaaa", required_arg: "yara", private_required_arg: "yeee") }

  it "allows use of #options to access required args" do
    expect(subject.required_up).to eq("YARA")
  end

  it "allows use of #options to access arity arguments" do
    expect(subject.arity_up).to eq("YAAA")
  end

  it "allows use of #options.fetch to provide default for optional args" do
    expect(subject.optional_up).to eq("DEFAULT")
  end

  it "does not allow access to private argument publicly" do
    expect { subject.private_arg }.to raise_error(NoMethodError)
  end

  it "allows access to private argument through #options" do
    expect(subject.options[:private_arg]).to eq("yas")
  end

  it "allows access to private argument internally" do
    expect(subject.private_up).to eq("YAS")
  end

  context "with optional_arg supplied" do
    subject do
      InstanceableClass.new(
        arity_arg:            "yaaa",
        required_arg:         "yara",
        private_required_arg: "yeee",
        optional_arg:         "yaoa",
      )
    end

    it "allows use of #options.fetch to safely access optional arguments" do
      expect(subject.optional_up).to eq("YAOA")
    end
  end

  context "with required option missing" do
    subject { InstanceableClass.new(arity_arg: 1, private_required_arg: 1) }

    it "raises an ArgumentError" do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
