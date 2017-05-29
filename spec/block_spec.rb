describe "OptStruct block usage" do
  PersonClass = OptStruct.new do
    required :first_name
    option :last_name

    def name
      [first_name, last_name].compact.join(" ")
    end
  end

  CarModule = OptStruct.build do
    required :make, :model
    options :year, transmission: "Automatic"

    def name
      [year, make, model].compact.join(" ")
    end
  end

  class CarClass
    include CarModule
  end

  describe "with .new" do
    subject { PersonClass }

    it "throws error when required keys missing" do
      expect{ subject.new }.to raise_error(ArgumentError)
    end

    it "adds block methods to instance methods" do
      value = subject.new(first_name: "Trish")
      expect(value.name).to eq("Trish")
      value.last_name = "Smith"
      expect(value.name).to eq("Trish Smith")
    end
  end

  describe "with .build" do
    subject { CarClass }

    it "throws error when required keys missing" do
      # binding.pry
      expect{ subject.new }.to raise_error(ArgumentError)
    end

    it "adds block methods to instance methods" do
      car1 = subject.new(make: "Infiniti", model: "G37", year: 2012)
      expect(car1.name).to eq("2012 Infiniti G37")
      car2 = subject.new(model: "WRX", make: "Subaru")
      expect(car2.name).to eq("Subaru WRX")
    end
  end
end
