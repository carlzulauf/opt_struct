describe "OptStruct block usage" do
  PersonClass = OptStruct.new do
    required :first_name
    option :last_name

    attr_reader :age

    init do
      @age = 0
    end

    def name
      [first_name, last_name].compact.join(" ")
    end
  end

  LoadsOfCallbacks = OptStruct.new do
    before_init { order << 2 }
    init { order << 3 }
    after_init { order << 4 }
    around_init { |i| order << 1; i.call; order << 5 }
    around_init :more_order

    def order
      @order ||= []
    end

    def more_order
      order << 0
      yield
      order << 6
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

  describe "with various callbacks" do
    subject { LoadsOfCallbacks.new }

    it "executes callbacks in a predictible order" do
      expect(subject.order).to eq((0..6).to_a)
    end
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

    it "executes the init block if present" do
      expect(subject.new(first_name: "Baby").age).to eq(0)
    end
  end

  describe "with .build" do
    subject { CarClass }

    it "throws error when required keys missing" do
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
