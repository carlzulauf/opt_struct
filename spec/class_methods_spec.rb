describe "Class methods added by OptStruct" do
  subject do
    OptStruct.new(:pos1, :pos2, opt1: :default, opt2: :default) do
      required :opt3
      option :opt4, default: :default
    end
  end

  describe "required_keys" do
    it "returns the keys for required options" do
      expect(subject.required_keys).to eq(%i[pos1 pos2 opt3])
    end
  end

  describe "defaults" do
    it "returns a Hash containing current defaults, indexed by their keys" do
      expect(subject.defaults).to eq({ opt1: :default, opt2: :default, opt4: :default })
    end
  end

  describe "expected_arguments" do
    it "returns the names of the positional arguments the struct expects" do
      expect(subject.expected_arguments).to eq(%i[pos1 pos2])
    end
  end

  describe "defined_keys" do
    it "returns the names of all options explicitly defined" do
      expect(subject.defined_keys).to eq(%i[pos1 pos2 opt1 opt2 opt3 opt4])
    end
  end

  describe "option" do
    subject { OptStruct.new }

    context "with a valid option" do
      it "adds option to list of defined keys" do
        expect { subject.option :valid }.to \
          change { subject.defined_keys }.
          from([]).
          to([:valid])
      end
    end

    context "with an option from the list of reserved words" do
      it "raises an ArgumentError" do
        expect { subject.option :fetch }.to raise_error(ArgumentError)
        expect { subject.option :check_required_keys }.to raise_error(ArgumentError)
        expect { subject.option :options }.to raise_error(ArgumentError)
        expect { subject.option :run_callback }.to raise_error(ArgumentError)
      end
    end
  end
end
